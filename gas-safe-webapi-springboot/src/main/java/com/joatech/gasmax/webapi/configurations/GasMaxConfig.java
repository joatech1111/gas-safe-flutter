package com.joatech.gasmax.webapi.configurations;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.stereotype.Component;

import lombok.Getter;
import lombok.Setter;

@Component
@Configuration
@Getter
@Setter
public class GasMaxConfig {

//	@Value("${gasmax.session.timeout}")
//	private Integer sessionTimeout;
	private Integer sessionTimeout = 86400; // 24 × 3600 = 86400초
	@Value("${gasmax.redis.host}")
	private String redisHost;

	@Value("${gasmax.redis.portnumber}")
	private Integer redisPortNumber;

	@Value("${gasmax.redis.database}")
	private Integer redisDatabase;

	@Value("${gasmax.datasource.host}")
	private String dbHostname;

	@Value("${gasmax.datasource.portnumber}")
	private Integer dbPortNumber;

	@Value("${gasmax.datasource.database}")
	private String dbName;

	@Value("${gasmax.datasource.username}")
	private String dbUsername;

	@Value("${gasmax.datasource.password}")
	private String dbPassword;
}
