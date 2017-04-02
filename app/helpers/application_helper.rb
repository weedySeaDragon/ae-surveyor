module ApplicationHelper


  ##
  # The page_title in the HEAD (meta) section
  #
  # if page_title is set to something, use it by getting it from content_for:
  # else
  #  if there is a page_title (used in the body of the page, usually as H1)
  #     use that value
  #  else  just return the default_title for the site
  #
  def meta_page_title(meta_page_title =  nil)
    if meta_page_title.present?
      content_for :meta_page_title, meta_page_title
    else
      content_for?(:page_title) ? content_for(:page_title) + ' | ' +  ENV['default_meta_page_title']  : ENV['default_meta_page_title']
    end
  end



  ##
  # return standardized html needed to show an item's attribute with the title (label) for the attribute
  # this will generate
  #  <[tag]><span class='item-title'>[title]</span>[separator][value]</[tag]>
  #
  # and will usually be used with the :p tag like this in a view:
  #  <%= show_item_title_and_value(:p, t('item_name'), @the_item.value) %>
  #    and assuming that t('item_name') gives us "Item Name" and @the_item.value == 'This is my name'
  #
  # this will return
  #  <p><span class='item-name'>Item Name</span>: <span class='item-value'>This is my name</span></p>
  #
  # Often the I18n.t entry key is the form [class].[attribute], in which case the above example
  # can become:
  # <%= show_item_title_and_value(:p, t("#{@the_item.class}.value"), @the_item.value) %>
  def show_item_title_and_value(tag, title, value, separator: ': ', title_class: 'item-title', value_class: 'item-value', tag_class: '')

    content_tag(tag, class: tag_class) do
      concat(content_tag(:span, title, class: "#{title_class}"))
      concat(separator)
      concat(content_tag(:span, value, class: "#{value_class}"))
    end
  end


  ##
  # Returns the meta_keywords on a per-page basis
  # if meta_keywords is set to something, store it using content_for:
  # else get the value for meta_keywords:
  #  if the content_for: meta_keywords is empty, just return the meta_keywords for the site
  def meta_keywords(tags = nil)
    if tags.present?
      content_for :meta_keywords, tags
    else
      content_for?(:meta_keywords) ? [content_for(:meta_keywords), ENV['meta_keywords']].join(', ') : ENV['meta_keywords']
    end
  end


  ##
  # Returns the meta_description on a per-page basis
  # if meta_description is set to something, store it using content_for:
  # else get the value for meta_description:
  #  if the content_for: meta_description is empty, just return the meta_description for the site
  def meta_description(desc = nil)
    if desc.present?
      content_for :meta_description, desc
    else
      content_for?(:meta_description) ? content_for(:meta_description) : ENV['meta_description']
    end
  end


  # return the content_tag for displaying an icon, given the icon class and (optionally) text
  def icon_tag(icon_class, text='')
    content_tag :i, text, {class: icon_class}
  end



  # call field_or_default with the default value = an empty String
  def field_or_none(label, value, tag: :p, tag_options: {}, separator: ': ',
                    label_class: 'field-label', value_class: 'field-value')

    field_or_default(label, value, default: '', tag: tag, tag_options: tag_options, separator: separator,
                     label_class: label_class, value_class: value_class)
  end


  # Return the HTML for a simple field with "Label: Value"
  # If value is blank, return the value of default (default value for default = '')
  # Surround it with the given content tag (default = :p if none provided)
  # and use the tag options (if any provided).
  # Default class to surround the label and separator is 'field-label'
  # Default class to surround the value is 'field-value'
  #
  # Separate the Label and Value with the separator string (default = ': ')
  #
  #  Ex:  field_or_none('Name', 'Bob Ross')
  #     will produce:  "<p><span class='field-label'>Name: </span><span class='field-value'>Bob Ross</span></p>"
  #
  #  Ex:  field_or_default('Name', '', default: '(no name provided)')
  #     will produce:  "(no name provided)"
  #
  #  Ex:  field_or_default('Name', '', default: content_tag( :h4, '(no name provided)', class: 'empty-warning') )
  #     will produce:  "<h4 class='empty-warning'>(no name provided)</h4>"
  #
  # Ex: field_or_none('Name', 'Bob Ross', tag: :h2, separator: ' = ')
  #     will produce:  "<h2><span class='field-label'>Name = </span><span class='field-value'>Bob Ross</span></h2>"
  #
  # Ex: field_or_none('Name', 'Bob Ross', tag_options: {id: 'bob-ross'}, value_class: 'special-value')
  #     will produce:  "<p id='bob-ross'><span class='field-label'>Name: </span><span class='special-value'>Bob Ross</span></p>"
  #
  def field_or_default(label, value, default: '', tag: :p, tag_options: {}, separator: ': ',
                       label_class: 'field-label', value_class: 'field-value')


    if value.blank?
      default
    else
      content_tag(tag, tag_options) do
        concat content_tag(:span, "#{label}#{separator}", class: label_class)
        concat content_tag(:span, value, class: value_class)
      end
    end

  end



  # Construct a string that can be used by CSS to style things in a particular view.
  def item_view_class(active_record_item, action_name)
    "#{action_name} #{active_record_item.class.name.downcase} #{unique_css_id(active_record_item)}"
  end


  # Construct a CSS identifier unique to this instance of an ActiveRecord
  # This is helpful so that this item can be uniquely identified on a page
  #  so that it can be (perhaps uniquely) styled.
  #
  # If the item does not have an ID, then we will have to assign on based on the
  # current UTC time in seconds, which will be of little use for CSS styling, but
  # there are no pretty alternatives.
  def unique_css_id(active_record_item)

    unique_id = if active_record_item.respond_to?(:id) && active_record_item.id
                  active_record_item.id.to_s
                else
                  "no-id--#{Time.now.utc.to_i}"
                end

    "#{active_record_item.class.name.downcase}-#{unique_id}"
  end




  #---------------------

  def flash_class(level)
    case level.to_sym
      when :notice then
        'success'
      when :alert then
        'danger'
    end
  end


  def flash_message(type, text)
    flash[type] ||= []
    if flash[type].instance_of? String
      flash[type] = [flash[type]]
    end
    flash[type] << text
  end


  def render_flash_message(flash_value)
    if flash_value.instance_of? String
      flash_value
    else
      safe_join(flash_value, '<br/>'.html_safe)
    end
  end


  def translate_and_join(error_list)
    error_list.map { |e| I18n.t(e) }.join(', ')
  end


end
