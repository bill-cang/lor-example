---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by root.
--- DateTime: 19-7-10 下午5:45
---

--database配置
return {
    -- mysql配置
    mysql = {
        timeout = 5000,
        connect_config = {
            host = "192.168.1.214",
            port = 3306,
            database = "lorex",
            user = "root",
            password = "123456",

            max_packet_size = 1024 * 1024
        },
        pool_config = {
            max_idle_timeout = 20000, -- 20s
            pool_size = 10000 -- connection pool size
        }
    },
    redis = {
        host = "r-t4n44e78691ca934.redis.singapore.rds.aliyuncs.com",
        password = "Piexgo2018",
        port = 6379,
        need_auth = 'true'
    },
}