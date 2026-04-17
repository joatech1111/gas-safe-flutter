package com.joatech.gasmax.webapi.services;

import java.util.List;
import java.util.Map;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.joatech.gasmax.webapi.configurations.GasMaxConfig;
import com.joatech.gasmax.webapi.domains.AppUserSafe;
import com.joatech.gasmax.webapi.domains.AppUserSafeRepository;

@Service
public class AppUserSafeService implements IAppUserSafeService {

	@Autowired
	private GasMaxConfig config;

	private AppUserSafeRepository repo;

	@Override
	public Optional<AppUserSafe> getAppUserSafeByHpImei(String hpImei) {
		try{
			repo = new AppUserSafeRepository(config.getDbHostname(), config.getDbPortNumber(), config.getDbName(), config.getDbUsername(), config.getDbPassword());
			Optional<AppUserSafe> optAppUserSafe = repo.findByHpImei(hpImei);

			System.out.println(optAppUserSafe);
			System.out.println(optAppUserSafe);
			System.out.println(optAppUserSafe);
			System.out.println(optAppUserSafe);


			repo.close();
			return optAppUserSafe;
		}catch(Exception e){

			System.out.println(e.getMessage());
			System.out.println(e.getMessage());
			System.out.println(e.getMessage());

		}


        return Optional.empty();
    }

	@Override
	public List<AppUserSafe> getAllAppUserSafe() {
		repo = new AppUserSafeRepository(config.getDbHostname(), config.getDbPortNumber(), config.getDbName(), config.getDbUsername(), config.getDbPassword());
		List<AppUserSafe> appUserSafeList = repo.findAll();
		repo.close();
		return appUserSafeList;
	}

	@Override
	public String getAppUserSafeAuthenticateInfo(String hpImei, String hpModel, String hpSNo, String appVer, String loginCo, String loginName, String loginUser, String loginPassword) {
		repo = new AppUserSafeRepository(config.getDbHostname(), config.getDbPortNumber(), config.getDbName(), config.getDbUsername(), config.getDbPassword());
		Map<String, Object> result = repo.executeAppUserSafeAuthenticate(hpImei, hpModel, hpSNo, appVer, loginCo, loginName, loginUser, loginPassword);
		String authInfo = (String)result.get("po_TRANS_INFO");
		repo.close();
		return authInfo;
	}

	@Override
	public Map<String, Object> addNewAppUserSafe(AppUserSafe appUserSafe) {
		repo = new AppUserSafeRepository(config.getDbHostname(), config.getDbPortNumber(), config.getDbName(), config.getDbUsername(), config.getDbPassword());
		Map<String, Object> result = repo.executeAppUserSafeAuthenticate(appUserSafe.getHpImei(), appUserSafe.getHpModel(), appUserSafe.getHpSNo(), appUserSafe.getAppVersion(), appUserSafe.getLoginCo(), appUserSafe.getLoginName(), appUserSafe.getLoginUser(), appUserSafe.getLoginPassword());
		repo.close();
		return result;
	}

	@Override
	public int updateAppUserSafe(String appVersion, String loginLastDate, String hpImei) {
		repo = new AppUserSafeRepository(config.getDbHostname(), config.getDbPortNumber(), config.getDbName(), config.getDbUsername(), config.getDbPassword());
		int rowCount = repo.updateAppUserSafeForAppVersionAndLoginLastDateByHpImei(appVersion, loginLastDate, hpImei);
		repo.close();
		return rowCount;
	}

}
