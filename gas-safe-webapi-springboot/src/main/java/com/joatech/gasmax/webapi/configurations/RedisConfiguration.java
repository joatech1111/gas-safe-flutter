package com.joatech.gasmax.webapi.configurations;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.data.redis.connection.RedisStandaloneConfiguration;
import org.springframework.data.redis.connection.lettuce.LettuceConnectionFactory;
import org.springframework.data.redis.core.RedisTemplate;

import com.joatech.gasmax.webapi.domains.AppUserSafe;

@Configuration
public class RedisConfiguration {
    
	@Autowired
	private GasMaxConfig gasMaxConfig;
	
    @Bean
    public RedisConnectionFactory redisConnectionFactory() {
        LettuceConnectionFactory lettuceConnectionFactory = new LettuceConnectionFactory();
        
        RedisStandaloneConfiguration config = lettuceConnectionFactory.getStandaloneConfiguration();
        config.setHostName(gasMaxConfig.getRedisHost());
        config.setPort(gasMaxConfig.getRedisPortNumber());
        config.setDatabase(gasMaxConfig.getRedisDatabase());
        
        return lettuceConnectionFactory;
    }

    @Bean
    public RedisTemplate<String, AppUserSafe> redisTemplate() {
        RedisTemplate<String, AppUserSafe> redisTemplate = new RedisTemplate<>();
        redisTemplate.setConnectionFactory(redisConnectionFactory());
        return redisTemplate;
    }
 
}