OmniAuth.config.test_mode = true

# provide a default working user
OmniAuth.config.mock_auth[:default] = OmniAuth::AuthHash.new(
    "provider"=>"saml",
    "uid"=>"waterfall-admin@example.com",
    "info"=>{
        "name"=>"Waterfall Admin",
        "email"=>"waterfall-admin@example.com",
        "first_name"=>"Waterfall",
        "last_name"=>"Admin"
    },
    "credentials"=>{},
    "extra"=>{
        "raw_info"=>{
            "email"=>"user@example.com",
            "first_name"=>"Test",
            "last_name"=>"User",
            "account_count"=>"3",
            "selected_account"=>"{\"uuid\":\"6888dce0-43d1-0131-9c64-482a14030d65\",\"name\":\"Demo account\"}",
            "modules_enabled"=>"[\"account\",\"cms\",\"crm\",\"forum\",\"university\"]",
            "account_type" => 'waterfall_admin'
        }
    }
)
OmniAuth.config.mock_auth[:invalid] = :invalid_credentials

OmniAuth.config.add_mock(:account_admin,{
    'uid' => 'admin@example.com',
    'info' => {
       'email'      => 'admin@example.com',
       'first_name' => 'Admin',
       'last_name'  => 'User'
    },
    'extra' => {
        'raw_info' => {
            'account_type' => 'admin'
        }
    }
})

OmniAuth.config.add_mock(:user,{
    'uid' => 'user@example.com',
    'info' => {
       'email'      => 'user@example.com',
       'first_name' => 'Normal',
       'last_name'  => 'User'
    },
    'extra' => {
        'raw_info' => {
            'account_type' => 'user'
        }
    }
})