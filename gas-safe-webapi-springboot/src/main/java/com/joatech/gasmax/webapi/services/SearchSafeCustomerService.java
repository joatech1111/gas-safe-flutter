package com.joatech.gasmax.webapi.services;

import java.util.List;
import java.util.Map;

import com.joatech.gasmax.webapi.domains.SafetyCustomer;
import com.joatech.gasmax.webapi.domains.SearchSafeCustomerRepository;

/*
 * 점검 거래처 검색(FN_점검 검색어 검색)
 */
public class SearchSafeCustomerService implements ISearchSafeCustomerService {
	
	private SearchSafeCustomerRepository repo;
	
	public SearchSafeCustomerService(String dbHostname, int dbPortNumber, String dbName, String dbUsername, String dbPassword) {
		repo = new SearchSafeCustomerRepository(dbHostname, dbPortNumber, dbName, dbUsername, dbPassword);
	}
	
	public void close() {
		repo.close();
	}
	

	@Override
	public List<Map<String, Object>> getAllSearchSafeCustomerBy(SafetyCustomer safetyCustomer) {

		return repo.findSafeCustomerBy(
				safetyCustomer.getAreaCode(),
				safetyCustomer.getFindStr(),
				safetyCustomer.getSafeFlan(),
				safetyCustomer.getCuType(),
				safetyCustomer.getCuCode(),
				safetyCustomer.getAptCd(),
				safetyCustomer.getSwCd(),
				safetyCustomer.getManCd(),
				safetyCustomer.getJyCd(),
				safetyCustomer.getAddrText(),
				safetyCustomer.getSuppYN(),
				safetyCustomer.getConformityYN(),
				safetyCustomer.getGpsX(),
				safetyCustomer.getGpsY());
	}
	
	@Override
	public List<Map<String, Object>> getAllSearchSafeCustomerByOrderBy(SafetyCustomer safetyCustomer) {

		return repo.findSafeCustomerByOrderBy(
				safetyCustomer.getAreaCode(),
				safetyCustomer.getFindStr(),
				safetyCustomer.getSafeFlan(),
				safetyCustomer.getCuType(),
				safetyCustomer.getCuCode(),
				safetyCustomer.getAptCd(),
				safetyCustomer.getSwCd(),
				safetyCustomer.getManCd(),
				safetyCustomer.getJyCd(),
				safetyCustomer.getAddrText(),
				safetyCustomer.getSuppYN(),
				safetyCustomer.getConformityYN(),
				safetyCustomer.getGpsX(),
				safetyCustomer.getGpsY(),
				safetyCustomer.getOrderBy());
	}

	@Override
	public List<Map<String, Object>> getGpsAllSearchSafeCustomerBy(SafetyCustomer safetyCustomer) {

		return repo.findGpsSafeCustomerBy(
				safetyCustomer.getAreaCode(),
				safetyCustomer.getFindStr(),
				safetyCustomer.getSafeFlan(),
				safetyCustomer.getCuType(),
				safetyCustomer.getCuCode(),
				safetyCustomer.getAptCd(),
				safetyCustomer.getSwCd(),
				safetyCustomer.getManCd(),
				safetyCustomer.getJyCd(),
				safetyCustomer.getAddrText(),
				safetyCustomer.getSuppYN(),
				safetyCustomer.getConformityYN(),
				safetyCustomer.getGpsX(),
				safetyCustomer.getGpsY());
	}
	
	@Override
	public List<Map<String, Object>> getGpsAllSearchSafeCustomerByOrderBy(SafetyCustomer safetyCustomer) {

		return repo.findGpsSafeCustomerByOrderBy(
				safetyCustomer.getAreaCode(),
				safetyCustomer.getFindStr(),
				safetyCustomer.getSafeFlan(),
				safetyCustomer.getCuType(),
				safetyCustomer.getCuCode(),
				safetyCustomer.getAptCd(),
				safetyCustomer.getSwCd(),
				safetyCustomer.getManCd(),
				safetyCustomer.getJyCd(),
				safetyCustomer.getAddrText(),
				safetyCustomer.getSuppYN(),
				safetyCustomer.getConformityYN(),
				safetyCustomer.getGpsX(),
				safetyCustomer.getGpsY(),
				safetyCustomer.getOrderBy());
	}

}
