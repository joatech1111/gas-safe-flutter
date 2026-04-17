package com.joatech.gasmax.webapi.services;

import java.util.UUID;
import java.util.concurrent.TimeUnit;

import javax.annotation.Resource;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.core.ValueOperations;
import org.springframework.stereotype.Service;

import com.joatech.gasmax.webapi.configurations.GasMaxConfig;
import com.joatech.gasmax.webapi.domains.AppUserSafe;

@Service
public class UserSessionService {
	/*================================================================
	 * Private Members
	 ================================================================*/
	@SuppressWarnings("unused")
	private final Logger logger = LoggerFactory.getLogger(getClass());

	/*================================================================
	 * Private Autowired Members
	 ================================================================*/
	@Autowired
	private RedisTemplate<String, AppUserSafe> redisTemplate;
	@Autowired
	private GasMaxConfig gasMaxConfig;
	
	@Resource(name = "redisTemplate")
	private ValueOperations<String, AppUserSafe> valueOps;
	
	/*================================================================
	 * Public Methods
	 ================================================================*/
	public String makeNewSession(AppUserSafe appUserSafe) {
		
		String sessionId = UUID.randomUUID().toString();
		String key = makeKey(sessionId);
		valueOps.set(key, appUserSafe, gasMaxConfig.getSessionTimeout(), TimeUnit.SECONDS);
		
		return sessionId;
	}

	public AppUserSafe getSessionInfo(String sessionId) {
		
		String key = makeKey(sessionId);
		AppUserSafe appUserSafe = valueOps.get(key);
		redisTemplate.expire(key, gasMaxConfig.getSessionTimeout(), TimeUnit.SECONDS);
		
		return appUserSafe;
	}
	
	public long getSessionTTL(String sessionId) {
		
		String key = makeKey(sessionId);
		long ttl = redisTemplate.getExpire(key);
		
		return ttl;
	}

	public long expireSession(String sessionId) {
		
		String key = makeKey(sessionId);
		redisTemplate.expire(key, 0, TimeUnit.SECONDS);
		long ttl = redisTemplate.getExpire(key);

		return ttl;
	}
	
	private String makeKey(String sessionId) {
		return "GasMaxApi:Session:" + sessionId;
	}

}
