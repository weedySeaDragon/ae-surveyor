require 'dotenv'

Dotenv.load('.env')


class SeedAdminENVError < StandardError
end

SEED_ERROR_MSG = 'Seed ERROR: Could not load either admin email or password. NO ADMIN was created!'



private def env_invalid_blank(env_key)
  raise SeedAdminENVError, SEED_ERROR_MSG if (env_val = ENV[env_key]).blank?
  env_val
end



if Rails.env.production?
  begin
    email = env_invalid_blank('ADMIN_EMAIL')
    pwd = env_invalid_blank('ADMIN_PWD')

    User.create(email: email, password: pwd, is_admin: true)
  rescue
    raise SeedAdminENVError, SEED_ERROR_MSG
  end


else
  email = 'admin@example.com'
  pwd = 'adminadminadmin'
  User.create(email: email, password: pwd, is_admin: true)
end
