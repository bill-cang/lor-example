local user_model = require "app.model.user_model"

local public_con = {

    authtoken_expire_times = 300 * 60,
    authtoken_suffix = "resty:login:web:",
    authtoken_suffix_app = "resty:login:app:",
    
	success = { err_code = 0, msg = "ok" },
    error = {
        login_true = { err_code = 0, msg = "ok", islogin = true },
        login_not = { err_code = 10001, msg = "Please login", islogin = false },
        login_expire = { err_code = 10002, msg = "Login has expired, Please login again", islogin = false },
        login_another = { err_code = 10003, msg = "Login on another device, Please login again", islogin = false },
        login_google_auth = { err_code = 10004, msg = "Google auth"},
        account_locked = { err_code = 10010, msg = "Unable to login, Please contact customer service", islogin = false },
        
        parameter_error = { err_code = 10100, msg = "Parameters Error" },
        network_error = { err_code = 10101, msg = "Network Error" },
        server_error = { err_code = 10102, msg = "Server Error" },
        submit_error = { err_code = 10103, msg = "Server Error" },
        redis_error = { err_code = 10104, msg = "Server Error" },
        network_expire_error = { err_code = 10105, msg = "Server timeout Error" },
        
        validate_error = { err_code = 10110, msg = "Please refresh the page to resubmit again" },
        token_error = { err_code = 10111, msg = "Wrong auth token, Please refresh" },
        email_error = { err_code = 10112, msg = "Email Format Error" },
        account_error = { err_code = 10113, msg = "Account already exists" },
        pwd_len_error = { err_code = 10114, msg = "Password length must be no less than 8" },
        login_error = { err_code = 10115, msg = "Invalid Username or Password" },
        auth_code_error = { err_code = 10116, msg = "Verification code error" },
        account_exist_error = { err_code = 10117, msg = "Account does not exist" },
        kyc_error = { err_code = 10118, msg = "Kyc error" },
        send_error = { err_code = 10119, msg = "Do not operate frequently"},
        auth_count_error = { err_code = 10120, msg = "Verification code count over limit"},
        pwd_error = { err_code = 10121, msg = "Password error"},
        

        market_error = { err_code = 10201, msg = "Market does not exist" },
        currency_error = { err_code = 10202, msg = "Symbol does not exist" },
        
        face_error = { err_code = 10210, msg = "Kyc count over limit" },
        
        price_error = { err_code = 10301, msg = "Price error" },
        volume_error = { err_code = 10302, msg = "Volume error" },
        precision_error = { err_code = 10303, msg = "Precision error" },
        order_type_error = { err_code = 10304, msg = "Order Type error" },

        balance_error = { err_code = 10400, msg = "Insufficient Balance" },
        btc_sum_error = { err_code = 10401, msg = "The total must be greater than 0.0001 BTC" },
        eth_sum_error = { err_code = 10402, msg = "The total must be greater than 0.001 ETH" },
        usd_sum_error = { err_code = 10403, msg = "The total m ust be greater than 1 USD" },  
    },
    
    white_list = {
        "/auth/authToken",
        "/auth/emailRegister",
        "/auth/phoneRegister",
        "/auth/login",
        "/auth/loginByTFA",
        "/auth/checkAccount",
        "/auth/resetEmailPassword",
        "/auth/resetPhonePassword",
        
        "/otc/entrustOrders",
        "/otc/markets",

        "/data/[0-9a-zA-Z-_]+$",
        "/activity/leaderBoard",
        "/activity/ixoStatus",
        "/activity/ixoResult",
        "/activity/edgeTotal",
    },

    auth_global_list = {
        "/activity/[0-9a-zA-Z-_]+$",
        "/user/userInfo",
        "/user/userAuthState",
        "/user/saveKYC",
        "/trade/assets",
        
        "/user/storeList",
        "/user/myStoreList",
        "/user/store",
        "/user/cancelStore",
        "/user/mineInfo",
        "/user/inviteInfo",
        "/user/myInviteeList",
        "/user/myInviteFeeList",
        "/user/myInviteBonus",
        "/activity/ixoSerial",
        "/activity/ixolottery",
    },
    
    symbol_pre = {
        ETH_USDT = {priceLimit = 2, numLimit = 4, fiatLimit = 2},
        BTC_USDT = {priceLimit = 2, numLimit = 4, fiatLimit = 2},
    },

    currency_info = {
        BTC = { name = "btc", type = "btc", fee = "0.0005", min_withdraw = "0.01", min_deposit = "0.0005", deposit_ctrl = 1, withdraw_ctrl = 1},
        USDT = { name = "usdt", type = "usdt", fee = "2", min_withdraw = "10", min_deposit = "1", deposit_ctrl = 1, withdraw_ctrl = 1},
        ETH = { name = "eth",  type = "eth", fee = "0.01", min_withdraw = "0.01", min_deposit = "0.01", deposit_ctrl = 1, withdraw_ctrl = 1},
    },

    otc_markets = {
        btc_cny =  { name = "btc_cny", target = "BTC", quote = "CNY", volume_precision = 2,volume_digit = 8,amount_precision = 4,amount_digit=6},
        eth_cny = { name = "eth_cny", target = "ETH", quote = "CNY", volume_precision = 2,volume_digit = 8,amount_precision = 4,amount_digit=6},
        usdt_cny = { name = "usdt_cny", target = "USDT", quote = "CNY", volume_precision = 2,volume_digit = 8,amount_precision = 2,amount_digit=6},
    }, 
    
    
    code_type = {
        register = 1,
        reset_passwd = 2,
        bind_phone_email = 3,
        otc_bind_payinfo = 4,
        google_auth = 5,
        withdraw = 6,
        otc_receipt = 7,
    },
    
    currency_rate = {
        USDCNY = 6.72,
    },
    
    banner = {
        ios = {scope = 1, redis_key = "resty:banner:ios"},
        android = {scope = 2, redis_key = "resty:banner:android"},
        web = {scope = 4, redis_key = "resty:banner:web"},
    },
}

function public_con:init()
 
    local res, err = user_model:select_symbol_info()  --交易对
    if not err then            
        public_con['symbol_pre'] = res
    else
        ngx.log(ngx.ERR, "public_con:init error.")
        return err
    end 

    local res, err = user_model:select_currency_info()   --币种
    if not err then            
        public_con['currency_info'] = res
    else
        ngx.log(ngx.ERR, "public_con:init error.")
        return err
    end

    local res, err = user_model:select_otc_market_info()   --otc config
    if not err then            
        public_con['otc_markets'] = res
    else
        ngx.log(ngx.ERR, "public_con:init error.")
        return err
    end
    
    ngx.log(ngx.ERR, "public_con:init success.")   
end


return public_con