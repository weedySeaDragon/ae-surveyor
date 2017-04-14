namespace :rasvals do


  desc "replace unicodes with real characters"
  task :replace_unicodes => [:environment] do

    # some letters are preceded by 1 \ and some by 2
    replacements = {
        "\\\\u00C4" => 'Ä',
        "\\\\u00C5" => 'Å',
        "\\\\u00C6" => 'Æ',
        "\\\\u00D6" => 'Ö',
        "\\u00C4" => 'Ä',
        "\\u00C5" => 'Å',
        "\\u00C6" => 'Æ',
        "\\u00D6" => 'Ö',

        "\\\\u00E4" => 'ä',
        "\\\\u00E5" => 'å',
        "\\\\u00E6" => 'æ',
        "\\\\u00E7" => 'ç',
        "\\\\u00E8" => 'è',
        "\\\\u00E9" => 'é',

        "\\\\u00F6" => 'ö',

        "\\\\u00FC" => 'ü',

        "\\u00E4" => 'ä',
        "\\u00E5" => 'å',
        "\\u00E6" => 'æ',
        "\\u00E7" => 'ç',
        "\\u00E8" => 'è',
        "\\u00E9" => 'é',
        "\\u00F6" => 'ö',

        "\\u00FC" => 'ü',

        "\u00E4" => 'ä',
        "\u00E5" => 'å',
        "\u00E6" => 'æ',
        "\u00E7" => 'ç',
        "\u00E8" => 'è',
        "\u00E9" => 'é',
        "\u00F6" => 'ö',
        "\u00FC" => 'ü',

        '\\ä' => 'ä',
        '\\å' => 'å',
        '\\æ' => 'æ',
        '\\ç' => 'ç',
        '\\è' => 'è',
        '\\é' => 'é',
        '\\ö' => 'ö',
        '\\ü' => 'ü',


    }


    breeds = BreedProfile.all

    breeds.each do |breed|

      replacements.each do |repl_unicode, repl_letter|
        breed.name.sub!(repl_unicode, repl_letter)
        breed.comments.sub!(repl_unicode, repl_letter)
      end

      breed.save

    end

  end


  desc 'create breed profiles CSV from 1 large orig'
  task :create_breed_profiles_csv => [:environment] do

    big_filename = 'docs/old-survey/orig-breeds-data.csv'
    breed_profiles_filename = 'docs/old-survey/orig-breed-profiles-data.csv'

    data = []
    options = {
        headers_in_file: true,
        verbose: true
    }
    File.open(big_filename, "r:bom|utf-8") do |f|
      data = SmarterCSV.process(big_filename, options);
    end

    # now process the information and turn it into what we really need
    final_breed_info = Array.new

    data.each do |breed_data|
      final_info = {}
      this_breed = breed_data.dup

      # 1. Breed name
      final_info[:name] = breed_data[:name]
      breed_data.reject! { |k, v| k == :name }


      # 2. Skip all of the quiz answer scores

      # have to loop through the values to find the first value that is LESS THAN the most recent score
      #  ex:
      #   the last answer score will look something like 702  ( = question 7, answer #2)
      #   the first value for the first breed profile aspect will be between 0 and 100 (highest = 100, lowest = 0)
      #  so when we find something like:
      #   current__value = 702
      #   next_value = 100
      #  then we know that 'next_value' is the start of the breed profile info

      keys = breed_data.keys.sort
      quiz_scores = {}
      i = 0
      current_val = breed_data[keys[i]]
      next_val = breed_data[keys[i + 1]] # assume breed_data.count > 1

      while (i + 2 < breed_data.count) && next_val.is_a?(Numeric) && (next_val > current_val)
        quiz_scores[keys[i]] = current_val

        i += 1
        current_val = next_val
        next_val = breed_data[keys[i + 1]] # assume breed_data.count > 1
      end
      quiz_scores[keys[i]] = current_val

      # remove the quiz scores to make it easier to do the next step(s)
      quiz_scores.keys.each { |quiz_score_k| breed_data.reject! { |k, v| k == quiz_score_k } }


      # 3. Breed Profile ('Monograph') info
      final_info[:breed_profile] = process_breed_profile breed_data # whatever remains is breed info

      final_breed_info << final_info
    end

    # now write the output:
    output_keys = [:name, :signal, :flock, :egna, :jakt, :apport, :vatten, :skall, :vakt, :comments]

    f = File.new(breed_profiles_filename, "w")

    # write the header
    f.puts output_keys.join(',')

    # write 1 line for each breed_info:
    final_breed_info.each { | breed_info | f.puts breed_profile_string(breed_info) }

    f.flush

    puts "\nFinished writing breed profile info to #{breed_profiles_filename}\n"
  end



  # return a 1-line string for the breed_info hash
  def breed_profile_string(breed_info)

    trait_keys = [:signal, :flock, :egna, :jakt, :apport, :vatten, :skall, :vakt]

    result = ""
    result << "#{breed_info[:name]},"
    trait_values = trait_keys.map{|trait| breed_info[:breed_profile][trait]}
    result << trait_values.join(',')
    result << ',' + breed_info[:breed_profile][:comments]
    result
  end

  desc "parse Breed info from CSV"
  task :parse_breed_csv_for_survey => [:environment] do

    # Each breed may have a different number of values on the CSV line.

    # 1. Breed name
    #  this is always the first entry
    #
    # 2. Quiz answer scores
    # the scores for the answers are 3 digits (a multiple of 100), where:
    #  the multiple of 100 (the first digit) = the question #
    #  the number of these _varies_ because only the answers where the
    #     breed should 'count' are listed
    #
    # 3. Breed Profile ('Monograph') info
    # the Breed profile values follow the questions, and are multiples of 10
    #  * there are always 7 of these
    #
    # Breed profile notes then follow, and can have a variable number of different entries
    #  * it's usually 2 text entries (strings), but sometimes more


    filename = 'docs/old-survey/orig-breeds-data.csv'
    options = {
        headers_in_file: true,
        verbose: true
    }

    data = []
    File.open(filename, "r:bom|utf-8") do |f|

      data = SmarterCSV.process(filename,  options);
    end

    # now process the information and turn it into what we really need
    data.each { |breed_data| puts breed_data }

    final_breed_info = Array.new

    data.each do | breed_data |
      final_info = {}
      this_breed = breed_data.dup

      # 1. Breed name
      final_info[:name] = breed_data[:name]
      breed_data.reject!{|k,v| k == :name }


      # 2. Quiz answer scores

      # have to loop through the values to find the first value that is LESS THAN the most recent score
      #  ex:
      #   the last answer score will look something like 702  ( = question 7, answer #2)
      #   the first value for the first breed profile aspect will be between 0 and 100 (highest = 100, lowest = 0)
      #  so when we find something like:
      #   current__value = 702
      #   next_value = 100
      #  then we know that 'next_value' is the start of the breed profile info

      keys = breed_data.keys.sort
      quiz_scores = {}
      i = 0
      current_val = breed_data[ keys[i] ]
      next_val = breed_data[  keys[i + 1] ] # assume breed_data.count > 1

      while (i + 2 < breed_data.count) && next_val.is_a?(Numeric) && ( next_val > current_val)
        quiz_scores[ keys[i] ] = current_val

        i += 1
       current_val = next_val
       next_val = breed_data[ keys[i + 1] ] # assume breed_data.count > 1
      end
      quiz_scores[ keys[i] ] = current_val

      final_info[:quiz_scores] =  decode_quiz_scores quiz_scores

      # remove the quiz scores to make it easier to do the next step(s)
      quiz_scores.keys.each { |quiz_score_k| breed_data.reject!{| k,v| k == quiz_score_k } }


      # 3. Breed Profile ('Monograph') info
      final_info[:breed_profile] =  process_breed_profile  breed_data  # whatever remains is breed info

      # breed info needs to be saved first because the quiz scores refer to it
      breed = save_breed_profile(final_info[:name], final_info[:breed_profile])

      save_breed_quiz_key(breed, final_info[:quiz_scores])

      final_breed_info << final_info
    end

    puts " "
    puts "--------------------"
    
    final_breed_info.each { |b| puts b }

  end


  # take the list of scores return an array with a hash for each where:
  #   question:            # the question #
  #   answer:              # the answer #
  #   value:               # the value for this breed if the user chooses this answer
  #
  # If the scores don't have any info for a particular question, there will
  # not be a hash entry for it.

  def decode_quiz_scores(scores)

    result = Array.new

    scores.each do | key, val |
      q_number = val / 100
      ans = val - (100 * q_number)
      result << {question: q_number, answer: ans, value: 1}
    end

    result
  end

  # Breed profile info
  #
  # 7 scores (1 for each breed profile aspect)
  # and comments
  #
  #  mono_signal.setPosition(int(aBreed.getMonography(0)));
  #  mono_flock.setPosition(int(aBreed.getMonography(1)));
  #  mono_egna.setPosition(int(aBreed.getMonography(2)));
  #  mono_jakt.setPosition(int(aBreed.getMonography(3)));
  #  mono_apport.setPosition(int(aBreed.getMonography(4)));
  #  mono_vatten.setPosition(int(aBreed.getMonography(5)));
  #  mono_skall.setPosition(int(aBreed.getMonography(6)));
  #  mono_vakt.setPosition(int(aBreed.getMonography(7)));

  BREED_ASPECTS = 8
  def process_breed_profile(profile_info)

    profile_keys = [:signal, :flock, :egna, :jakt, :apport, :vatten, :skall, :vakt]

    result = {}

    # profile scores
    profile_scores = profile_info.values

    profile_keys.count.times  do | i |
      result[ profile_keys[i] ] = profile_scores[i]
    end

    # the rest are profile comments

    comments = (profile_scores[BREED_ASPECTS..(profile_scores.count - 1)])

    result[:comments] = comments.join(';')
    result
  end


  def save_breed_profile(name, breed_profile)
    breed = BreedProfile.new(name: name,
                     signal: breed_profile[:signal],
                     flock: breed_profile[:flock],
                     egna: breed_profile[:egna],
                     jakt: breed_profile[:jakt],
                     apport: breed_profile[:apport],
                     vatten: breed_profile[:vatten],
                     skall: breed_profile[:skall],
                     vakt: breed_profile[:vakt],
                     comments: breed_profile[:comments]
    )
    breed.save

    breed
  end


  # Save an entry for each answer that should get counted toward the breed
  # The default value to save (to count toward the breed) == 1

  DEFAULT_WEIGHT = 1


  def save_breed_quiz_key(breed, quiz_key_scores)

    quiz_key_scores.each do |breed_qa_score|

      breed_key = BreedQuizScoringKey.new(breed_profile: breed,
                                          question_id: breed_qa_score[:question],
                                          answer_id: breed_qa_score[:answer],
                                          score_value: DEFAULT_WEIGHT
      )
      breed_key.save

    end


  end

end