package com.joatech.gasmax.webapi.services;

import java.util.Map;
import com.joatech.gasmax.webapi.domains.ConfigSet;
import com.joatech.gasmax.webapi.domains.ConfigSetRepository;

/*
 * 환경 설정 저장(SP 환경 저장)
 */
public class ConfigSetService implements IConfigSetService {
	
	private ConfigSetRepository repo;
	
	public ConfigSetService(String dbHostname, int dbPortNumber, String dbName, String dbUsername, String dbPassword) {
		repo = new ConfigSetRepository(dbHostname, dbPortNumber, dbName, dbUsername, dbPassword);
	}
	
	public void close() {
		repo.close();
	}

	@Override
	public Map<String, Object> updateConfigSet(ConfigSet configSet) {
		
		return repo.executeConfigSet(
				configSet.getHpImei(),
				configSet.getLoginUser(),
				configSet.getLoginPass(),
				configSet.getSafeSwCode(),
				configSet.getAreaCode(),
				configSet.getSwCode(),
				configSet.getGubunCode(),
				configSet.getJyCode(),
				configSet.getOrderBy());

	}

}
