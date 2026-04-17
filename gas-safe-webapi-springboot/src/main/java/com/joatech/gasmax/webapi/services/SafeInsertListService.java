package com.joatech.gasmax.webapi.services;

import java.util.List;
import java.util.Map;

import com.joatech.gasmax.webapi.domains.SafeInsertList;
import com.joatech.gasmax.webapi.domains.SafeInsertListRepository;

/*
 * 점검현황(FN점검현황 )
 * 
 * 안전 검침 현황
 * 2019.12.12 수정 - SAFE_CD, APP_User 추가
 */
public class SafeInsertListService implements ISafeInsertListService {
	
	private SafeInsertListRepository repo;
	
	public SafeInsertListService(String dbHostname, int dbPortNumber, String dbName, String dbUsername, String dbPassword) {
		repo = new SafeInsertListRepository(dbHostname, dbPortNumber, dbName, dbUsername, dbPassword);
	}
	
	public void close() {
		repo.close();
	}
	
	@Override
	public List<Map<String, Object>> getSafeInsertListServiceBy(SafeInsertList safeInsertList) {

		return repo.findSafeInsertListBy(
				safeInsertList.getAreaCode(),
				safeInsertList.getFindStr(),
				safeInsertList.getGumDateF(),
				safeInsertList.getGumDateT(),
				safeInsertList.getCuType(),
				safeInsertList.getCuCode(),
				safeInsertList.getAptCd(),
				safeInsertList.getSwCd(),
				safeInsertList.getManCd(),
				safeInsertList.getJyCd(),
				safeInsertList.getAddrText(),
				safeInsertList.getSuppYN(),
				safeInsertList.getConformityYN(),
				safeInsertList.getGpsX(),
				safeInsertList.getGpsY(),
				safeInsertList.getSafeCd(),
				safeInsertList.getAppUser());
	}
	
	@Override
	public List<Map<String, Object>> getSafeInsertListServiceByOrderBy(SafeInsertList safeInsertList) {
		return repo.findSafeInsertListByOrderBy(
				safeInsertList.getAreaCode(),
				safeInsertList.getFindStr(),
				safeInsertList.getGumDateF(),
				safeInsertList.getGumDateT(),
				safeInsertList.getCuType(),
				safeInsertList.getCuCode(),
				safeInsertList.getAptCd(),
				safeInsertList.getSwCd(),
				safeInsertList.getManCd(),
				safeInsertList.getJyCd(),
				safeInsertList.getAddrText(),
				safeInsertList.getSuppYN(),
				safeInsertList.getConformityYN(),
				safeInsertList.getGpsX(),
				safeInsertList.getGpsY(),
				safeInsertList.getSafeCd(),
				safeInsertList.getAppUser(),
				safeInsertList.getOrderBy());
	}

	@Override
	public List<Map<String, Object>> getGpsSafeInsertListeServiceBy(SafeInsertList safeInsertList) {
		return repo.findGpsSafeInsertListBy(
				safeInsertList.getAreaCode(),
				safeInsertList.getFindStr(),
				safeInsertList.getGumDateF(),
				safeInsertList.getGumDateT(),
				safeInsertList.getCuType(),
				safeInsertList.getCuCode(),
				safeInsertList.getAptCd(),
				safeInsertList.getSwCd(),
				safeInsertList.getManCd(),
				safeInsertList.getJyCd(),
				safeInsertList.getAddrText(),
				safeInsertList.getSuppYN(),
				safeInsertList.getConformityYN(),
				safeInsertList.getGpsX(),
				safeInsertList.getGpsY(),
				safeInsertList.getSafeCd(),
				safeInsertList.getAppUser());
	}
	
	@Override
	public List<Map<String, Object>> getGpsSafeInsertListeServiceByOrderBy(SafeInsertList safeInsertList) {
	
		return repo.findGpsSafeInsertListByOrderBy(
				safeInsertList.getAreaCode(),
				safeInsertList.getFindStr(),
				safeInsertList.getGumDateF(),
				safeInsertList.getGumDateT(),
				safeInsertList.getCuType(),
				safeInsertList.getCuCode(),
				safeInsertList.getAptCd(),
				safeInsertList.getSwCd(),
				safeInsertList.getManCd(),
				safeInsertList.getJyCd(),
				safeInsertList.getAddrText(),
				safeInsertList.getSuppYN(),
				safeInsertList.getConformityYN(),
				safeInsertList.getGpsX(),
				safeInsertList.getGpsY(),
				safeInsertList.getSafeCd(),
				safeInsertList.getAppUser(),
				safeInsertList.getOrderBy());
	}


}
