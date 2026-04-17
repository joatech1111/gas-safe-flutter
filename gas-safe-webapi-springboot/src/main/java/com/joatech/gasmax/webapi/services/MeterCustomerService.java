package com.joatech.gasmax.webapi.services;

import java.util.List;
import java.util.Map;

import com.joatech.gasmax.webapi.domains.CustomerMeterInfo;
import com.joatech.gasmax.webapi.domains.CustomerMeterInfoUpdateRepository;
import com.joatech.gasmax.webapi.domains.MeterCheckStatusInfo;
import com.joatech.gasmax.webapi.domains.MeterCustomer;
import com.joatech.gasmax.webapi.domains.MeterCustomerSearchRepository;
import com.joatech.gasmax.webapi.domains.MeterInsertRepository;
import com.joatech.gasmax.webapi.domains.SaveMeterValue;
import com.joatech.gasmax.webapi.domains.SaveMeterValueRepository;


/*
 *검침 거래처 검색(FN_검침 거래처 검색)
 */
public class MeterCustomerService implements IMeterCustomerService {
	
	private MeterCustomerSearchRepository repo;
	private SaveMeterValueRepository repoSaveMeterValue;
	private CustomerMeterInfoUpdateRepository repoCustomerMeterInfo;
	private MeterInsertRepository repoMeterInsert;

	public MeterCustomerService(String dbHostname, int dbPortNumber, String dbName, String dbUsername, String dbPassword) {
		repo = new MeterCustomerSearchRepository(dbHostname, dbPortNumber, dbName, dbUsername, dbPassword);
		repoSaveMeterValue = new SaveMeterValueRepository(dbHostname, dbPortNumber, dbName, dbUsername, dbPassword);
		repoCustomerMeterInfo = new CustomerMeterInfoUpdateRepository(dbHostname, dbPortNumber, dbName, dbUsername, dbPassword);
		repoMeterInsert = new MeterInsertRepository(dbHostname, dbPortNumber, dbName, dbUsername, dbPassword);
	}
	
	public void close() {
		repo.close();
		repoSaveMeterValue.close();
		repoCustomerMeterInfo.close();
		repoMeterInsert.close();
	}

	/*
	 * 전체 검침거래처
	 */
	@Override
	public List<Map<String, Object>> getAllSearchMeterCustomerListBy(MeterCustomer meterCustomer) {
		
		List<Map<String, Object>> resultList = null;
		
		if (meterCustomer.getOrderBy().length() == 0) {
			resultList = repo.findAllMeterCustomerBy(
					meterCustomer.getAreaCode(), 
					meterCustomer.getFindStr(), 
					meterCustomer.getGumDate(), 
					meterCustomer.getSuppYN(), 
					meterCustomer.getGumYMSNo(), 
					meterCustomer.getGumTerm(), 
					meterCustomer.getGumMMDD(),
					meterCustomer.getCuCode(),
					meterCustomer.getAptCd(),
					meterCustomer.getSwCd(),
					meterCustomer.getManCd(), 
					meterCustomer.getJyCd(),
					meterCustomer.getAddrText(),
					meterCustomer.getSmartMeterYN(),
					meterCustomer.getGpsX(), 
					meterCustomer.getGpsY());
		} else {
			resultList = repo.findAllMeterCustomerByOrderBy(
					meterCustomer.getAreaCode(), 
					meterCustomer.getFindStr(), 
					meterCustomer.getGumDate(), 
					meterCustomer.getSuppYN(), 
					meterCustomer.getGumYMSNo(), 
					meterCustomer.getGumTerm(), 
					meterCustomer.getGumMMDD(),
					meterCustomer.getCuCode(),
					meterCustomer.getAptCd(),
					meterCustomer.getSwCd(),
					meterCustomer.getManCd(), 
					meterCustomer.getJyCd(),
					meterCustomer.getAddrText(),
					meterCustomer.getSmartMeterYN(),
					meterCustomer.getGpsX(),
					meterCustomer.getGpsY(),
					meterCustomer.getOrderBy());
		}
		
		return resultList;
	}

	/*
	 * 회차별 검침거래처
	 */
	@Override
	public List<Map<String, Object>> getSNoSearchMeterCustomerListBy(MeterCustomer meterCustomer) {

		List<Map<String, Object>> resultList = null;
		
		if (meterCustomer.getOrderBy().length() == 0) {
			resultList = repo.findSNoMeterCustomerBy(
					meterCustomer.getAreaCode(), 
					meterCustomer.getFindStr(), 
					meterCustomer.getGumDate(), 
					meterCustomer.getSuppYN(), 
					meterCustomer.getGumYMSNo(), 
					meterCustomer.getGumTerm(), 
					meterCustomer.getGumMMDD(),
					meterCustomer.getCuCode(),
					meterCustomer.getAptCd(),
					meterCustomer.getSwCd(),
					meterCustomer.getManCd(), 
					meterCustomer.getJyCd(),
					meterCustomer.getAddrText(),
					meterCustomer.getSmartMeterYN(),
					meterCustomer.getGpsX(), 
					meterCustomer.getGpsY());
		} else {
			resultList = repo.findSNoMeterCustomerByOrderBy(
					meterCustomer.getAreaCode(), 
					meterCustomer.getFindStr(), 
					meterCustomer.getGumDate(), 
					meterCustomer.getSuppYN(), 
					meterCustomer.getGumYMSNo(), 
					meterCustomer.getGumTerm(), 
					meterCustomer.getGumMMDD(),
					meterCustomer.getCuCode(),
					meterCustomer.getAptCd(),
					meterCustomer.getSwCd(),
					meterCustomer.getManCd(), 
					meterCustomer.getJyCd(),
					meterCustomer.getAddrText(),
					meterCustomer.getSmartMeterYN(),
					meterCustomer.getGpsX(),
					meterCustomer.getGpsY(),
					meterCustomer.getOrderBy());
		}
		
		return resultList;
	}

	/*
	 * 검침주기 검침거래처
	 */
	@Override
	public List<Map<String, Object>> getTurmSearchMeterCustomerListBy(MeterCustomer meterCustomer) {
		
		List<Map<String, Object>> resultList = null;
		
		if (meterCustomer.getOrderBy().length() == 0) {
			resultList = repo.findTurmMeterCustomerBy(
					meterCustomer.getAreaCode(), 
					meterCustomer.getFindStr(), 
					meterCustomer.getGumDate(), 
					meterCustomer.getSuppYN(), 
					meterCustomer.getGumYMSNo(), 
					meterCustomer.getGumTerm(), 
					meterCustomer.getGumMMDD(),
					meterCustomer.getCuCode(),
					meterCustomer.getAptCd(),
					meterCustomer.getSwCd(),
					meterCustomer.getManCd(), 
					meterCustomer.getJyCd(),
					meterCustomer.getAddrText(),
					meterCustomer.getSmartMeterYN(),
					meterCustomer.getGpsX(), 
					meterCustomer.getGpsY());
		} else {
			resultList = repo.findTurmMeterCustomerByOrderBy(
					meterCustomer.getAreaCode(), 
					meterCustomer.getFindStr(), 
					meterCustomer.getGumDate(), 
					meterCustomer.getSuppYN(), 
					meterCustomer.getGumYMSNo(), 
					meterCustomer.getGumTerm(), 
					meterCustomer.getGumMMDD(),
					meterCustomer.getCuCode(),
					meterCustomer.getAptCd(),
					meterCustomer.getSwCd(),
					meterCustomer.getManCd(), 
					meterCustomer.getJyCd(),
					meterCustomer.getAddrText(),
					meterCustomer.getSmartMeterYN(),
					meterCustomer.getGpsX(),
					meterCustomer.getGpsY(),
					meterCustomer.getOrderBy());
		}

		return resultList;
	}

	/*
	 * GPS 좌표 검색
	 */
	@Override
	public List<Map<String, Object>> getGpsSearchMeterCustomerListBy(MeterCustomer meterCustomer) {
		
		List<Map<String, Object>> resultList = null;
		
		if (meterCustomer.getOrderBy().length() == 0) {
			resultList = repo.findGpsMeterCustomerBy(
					meterCustomer.getAreaCode(), 
					meterCustomer.getFindStr(), 
					meterCustomer.getGumDate(), 
					meterCustomer.getSuppYN(), 
					meterCustomer.getGumYMSNo(), 
					meterCustomer.getGumTerm(), 
					meterCustomer.getGumMMDD(),
					meterCustomer.getCuCode(),
					meterCustomer.getAptCd(),
					meterCustomer.getSwCd(),
					meterCustomer.getManCd(), 
					meterCustomer.getJyCd(),
					meterCustomer.getAddrText(),
					meterCustomer.getSmartMeterYN(),
					meterCustomer.getGpsX(), 
					meterCustomer.getGpsY());
		} else {
			resultList = repo.findGpsMeterCustomerByOrderBy(
					meterCustomer.getAreaCode(), 
					meterCustomer.getFindStr(), 
					meterCustomer.getGumDate(), 
					meterCustomer.getSuppYN(), 
					meterCustomer.getGumYMSNo(), 
					meterCustomer.getGumTerm(), 
					meterCustomer.getGumMMDD(),
					meterCustomer.getCuCode(),
					meterCustomer.getAptCd(),
					meterCustomer.getSwCd(),
					meterCustomer.getManCd(), 
					meterCustomer.getJyCd(),
					meterCustomer.getAddrText(),
					meterCustomer.getSmartMeterYN(),
					meterCustomer.getGpsX(),
					meterCustomer.getGpsY(),
					meterCustomer.getOrderBy());
		}

		return resultList;
	}

	// 검침 현황 검색
	/*
	 * 모바일 검침 현황
	 * 2019.12.12 수정 - SAFE_CD, APP_User 추가
	 */
	@Override
	public List<Map<String, Object>> getMeterCheckStatusListBy(MeterCheckStatusInfo meterCheckStatusInfo) {

		List<Map<String, Object>> resultList = null;
		
		if (meterCheckStatusInfo.getOrderBy().length() == 0) {
			resultList = repoMeterInsert.findMeterInsertListBy(
					meterCheckStatusInfo.getAreaCode(), 
					meterCheckStatusInfo.getFindStr(), 
					meterCheckStatusInfo.getGumDateF(), 
					meterCheckStatusInfo.getGumDateT(), 
					meterCheckStatusInfo.getCuCode(),
					meterCheckStatusInfo.getAptCd(),
					meterCheckStatusInfo.getSwCd(),
					meterCheckStatusInfo.getManCd(), 
					meterCheckStatusInfo.getJyCd(),
					meterCheckStatusInfo.getAddrText(),
					meterCheckStatusInfo.getSmartMeterYN(),
					meterCheckStatusInfo.getGpsX(), 
					meterCheckStatusInfo.getGpsY(),
					meterCheckStatusInfo.getSafeCd(),
					meterCheckStatusInfo.getAppUser());
		} else {
			resultList = repoMeterInsert.findMeterInsertListByOrderBy(
					meterCheckStatusInfo.getAreaCode(), 
					meterCheckStatusInfo.getFindStr(), 
					meterCheckStatusInfo.getGumDateF(), 
					meterCheckStatusInfo.getGumDateT(), 
					meterCheckStatusInfo.getCuCode(),
					meterCheckStatusInfo.getAptCd(),
					meterCheckStatusInfo.getSwCd(),
					meterCheckStatusInfo.getManCd(), 
					meterCheckStatusInfo.getJyCd(),
					meterCheckStatusInfo.getAddrText(),
					meterCheckStatusInfo.getSmartMeterYN(),
					meterCheckStatusInfo.getGpsX(), 
					meterCheckStatusInfo.getGpsY(),
					meterCheckStatusInfo.getSafeCd(),
					meterCheckStatusInfo.getAppUser(),
					meterCheckStatusInfo.getOrderBy());
		}
		
		return resultList;	
	}

	// 검침 현황 검색 - GPS
	/*
	 * 모바일 검침 현황
	 * 2019.12.12 수정 - SAFE_CD, APP_User 추가
	 */
	@Override
	public List<Map<String, Object>> getGpsMeterCheckStatusListBy(MeterCheckStatusInfo meterCheckStatusInfo) {

		List<Map<String, Object>> resultList = null;
		
		if (meterCheckStatusInfo.getOrderBy().length() == 0) {
			resultList = repoMeterInsert.findGpsMeterInsertListBy(
					meterCheckStatusInfo.getAreaCode(), 
					meterCheckStatusInfo.getFindStr(), 
					meterCheckStatusInfo.getGumDateF(), 
					meterCheckStatusInfo.getGumDateT(), 
					meterCheckStatusInfo.getCuCode(),
					meterCheckStatusInfo.getAptCd(),
					meterCheckStatusInfo.getSwCd(),
					meterCheckStatusInfo.getManCd(), 
					meterCheckStatusInfo.getJyCd(),
					meterCheckStatusInfo.getAddrText(),
					meterCheckStatusInfo.getSmartMeterYN(),
					meterCheckStatusInfo.getGpsX(), 
					meterCheckStatusInfo.getGpsY(),
					meterCheckStatusInfo.getSafeCd(),
					meterCheckStatusInfo.getAppUser());
		} else {
			resultList = repoMeterInsert.findGpsMeterInsertListByOrderBy(
					meterCheckStatusInfo.getAreaCode(), 
					meterCheckStatusInfo.getFindStr(), 
					meterCheckStatusInfo.getGumDateF(), 
					meterCheckStatusInfo.getGumDateT(), 
					meterCheckStatusInfo.getCuCode(),
					meterCheckStatusInfo.getAptCd(),
					meterCheckStatusInfo.getSwCd(),
					meterCheckStatusInfo.getManCd(), 
					meterCheckStatusInfo.getJyCd(),
					meterCheckStatusInfo.getAddrText(),
					meterCheckStatusInfo.getSmartMeterYN(),
					meterCheckStatusInfo.getGpsX(), 
					meterCheckStatusInfo.getGpsY(),
					meterCheckStatusInfo.getSafeCd(),
					meterCheckStatusInfo.getAppUser(),
					meterCheckStatusInfo.getOrderBy());
		}
		
		return resultList;	
	}

	// Add New
	@Override
	public Map<String, Object> addNewSaveMeterValue(SaveMeterValue saveMeterValue) {
		
		Map<String, Object> result;
		saveMeterValue.setSaveDiv("I");
		
		result = repoSaveMeterValue.executeSaveMeterValue(
				saveMeterValue.getSaveDiv(), 
				saveMeterValue.getAreaCode(), 
				saveMeterValue.getCuCode(), 
				saveMeterValue.getGjDate(), 
				saveMeterValue.getGjGumYM(), 
				saveMeterValue.getCuName(),
				saveMeterValue.getCuUserName(), 
				saveMeterValue.getGjJunGum(), 
				saveMeterValue.getGjGum(), 
				saveMeterValue.getGjGage(), 
				saveMeterValue.getGjT1Per(), 
				saveMeterValue.getGjT1Kg(),
				saveMeterValue.getGjT2Per(),
				saveMeterValue.getGjT2Kg(),
				saveMeterValue.getGjJanKg(),
				saveMeterValue.getGjBigo(),
				saveMeterValue.getSafeSwCode(),
				saveMeterValue.getSafeSwName(),
				saveMeterValue.getGpsX(),
				saveMeterValue.getGpsY(),
				saveMeterValue.getAppUser());
		
		return result;
	}

	// Update
	@Override
	public Map<String, Object> updateSaveMeterValue(SaveMeterValue saveMeterValue) {
		
		Map<String, Object> result;
		saveMeterValue.setSaveDiv("U");
		
		result = repoSaveMeterValue.executeSaveMeterValue(
				saveMeterValue.getSaveDiv(), 
				saveMeterValue.getAreaCode(), 
				saveMeterValue.getCuCode(), 
				saveMeterValue.getGjDate(), 
				saveMeterValue.getGjGumYM(), 
				saveMeterValue.getCuName(),
				saveMeterValue.getCuUserName(), 
				saveMeterValue.getGjJunGum(), 
				saveMeterValue.getGjGum(), 
				saveMeterValue.getGjGage(), 
				saveMeterValue.getGjT1Per(), 
				saveMeterValue.getGjT1Kg(),
				saveMeterValue.getGjT2Per(),
				saveMeterValue.getGjT2Kg(),
				saveMeterValue.getGjJanKg(),
				saveMeterValue.getGjBigo(),
				saveMeterValue.getSafeSwCode(),
				saveMeterValue.getSafeSwName(),
				saveMeterValue.getGpsX(),
				saveMeterValue.getGpsY(),
				saveMeterValue.getAppUser());
		
		return result;
	}
	
	// Delete
	@Override
	public Map<String, Object> deleteSaveMeterValue(SaveMeterValue saveMeterValue) {
		
		Map<String, Object> result;
		saveMeterValue.setSaveDiv("D");
		
		result = repoSaveMeterValue.executeSaveMeterValue(
				saveMeterValue.getSaveDiv(), 
				saveMeterValue.getAreaCode(), 
				saveMeterValue.getCuCode(), 
				saveMeterValue.getGjDate(), 
				saveMeterValue.getGjGumYM(), 
				saveMeterValue.getCuName(),
				saveMeterValue.getCuUserName(), 
				saveMeterValue.getGjJunGum(), 
				saveMeterValue.getGjGum(), 
				saveMeterValue.getGjGage(), 
				saveMeterValue.getGjT1Per(), 
				saveMeterValue.getGjT1Kg(),
				saveMeterValue.getGjT2Per(),
				saveMeterValue.getGjT2Kg(),
				saveMeterValue.getGjJanKg(),
				saveMeterValue.getGjBigo(),
				saveMeterValue.getSafeSwCode(),
				saveMeterValue.getSafeSwName(),
				saveMeterValue.getGpsX(),
				saveMeterValue.getGpsY(),
				saveMeterValue.getAppUser());
		
		return result;
	}
	
	@Override
	public Map<String, Object> updateCustomerMeterInfo(CustomerMeterInfo customerMeterInfo) {
		
		Map<String, Object> result = repoCustomerMeterInfo.executeCustomerMeterInfoUpdate(
				customerMeterInfo.getAreaCode(),
				customerMeterInfo.getCuCode(),
				customerMeterInfo.getCuGumTerm(),
				customerMeterInfo.getCuGumDate(),
				customerMeterInfo.getCuBarCode(),
				customerMeterInfo.getCuMeterNo(),
				customerMeterInfo.getCuMeterCo(),
				customerMeterInfo.getCuMeterLR(),
				customerMeterInfo.getCuMeterType(),
				customerMeterInfo.getCuMeterM3(),
				customerMeterInfo.getCuMeterDT(),
				customerMeterInfo.getAppUser());
		
		return result;
	}
}
