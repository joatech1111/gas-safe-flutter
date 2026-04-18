package com.joatech.gasmax.webapi.services;

import java.util.List;
import java.util.Map;
import java.util.Optional;

import com.joatech.gasmax.webapi.domains.AppUserSafe;

public interface IAppUserSafeService {
	
	Optional<AppUserSafe> getAppUserSafeByHpImei(String hpImei);
	List<AppUserSafe> getAppUserSafeListByHpSNo(String hpSNo);
	List<AppUserSafe> getAllAppUserSafe();
	String getAppUserSafeAuthenticateInfo(String hpImei, String hpModel, String hpSNo, String appVer, String loginCo, String loginName, String loginUser, String loginPassword);
	
	Map<String, Object> addNewAppUserSafe(AppUserSafe appUserSafe);
	int updateAppUserSafe(String appVersion, String loginLastDate, String hpImei);
	
}
