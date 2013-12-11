OmniAuth.config.test_mode = true

# provide a default working user
OmniAuth.config.mock_auth[:default] = OmniAuth::AuthHash.new(
    "provider"=>"saml",
    "uid"=>"user@example.com",
    "info"=>{
        "name"=>"Test User",
        "email"=>"user@example.com",
        "first_name"=>"Test",
        "last_name"=>"User"
    },
    "credentials"=>{},
    "extra"=>{
        "raw_info"=>{
            "email"=>"user@example.com",
            "first_name"=>"Test",
            "last_name"=>"User",
            "account_count"=>"3",
            "selected_account"=>"{\"uuid\":\"6888dce0-43d1-0131-9c64-482a14030d65\",\"name\":\"Demo account\"}",
            "modules_enabled"=>"[\"account\",\"cms\",\"crm\",\"forum\",\"university\"]"
        }
    }
)
OmniAuth.config.mock_auth[:invalid] = :invalid_credentials

