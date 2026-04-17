package com.joatech.gasmax.webapi;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration;
import org.springframework.context.annotation.PropertySource;

import com.joatech.gasmax.webapi.configurations.YamlPropertySourceFactory;

@SpringBootApplication(exclude = { DataSourceAutoConfiguration.class })
@PropertySource(
		factory = YamlPropertySourceFactory.class,
		value = { "classpath:config/gasmax.yml", "file:./config/gasmax.yml" },
		ignoreResourceNotFound = true
)
public class JoatechGasmaxWebapiApplication {

	public static void main(String[] args) {
		SpringApplication.run(JoatechGasmaxWebapiApplication.class, args);
	}

}
