package com.joatech.gasmax.webapi.services;

import java.util.List;
import java.util.Map;

import com.joatech.gasmax.webapi.domains.AnSobiSafe;
import com.joatech.gasmax.webapi.domains.AnSobiSafeRepository;

/*
 * 사용시설점검 Select View
 */
public class AnSobiSafeService implements IAnSobiSafeService {
	
	private AnSobiSafeRepository repo;
	
	public AnSobiSafeService(String dbHostname, int dbPortNumber, String dbName, String dbUsername, String dbPassword) {
		repo = new AnSobiSafeRepository(dbHostname, dbPortNumber, dbName, dbUsername, dbPassword);
	}
	
	public void close() {
		repo.close();
	}
	
	@Override
	public List<Map<String, Object>> getAnSobiSafeServiceBy(String areaCode, String anzCuCode, String anzSno) {
		return repo.findSelectAnSobiSafeBy(areaCode, anzCuCode, anzSno);
	}

	@Override
	public List<Map<String, Object>> getLastAnSobiSafeBy(String areaCode, String anzCuCode) {
		return repo.findLastSelectAnSobiSafeBy(areaCode, anzCuCode);
	}

	@Override
	public Map<String, Object> addNewAnSobiSafe(AnSobiSafe anSobiSafe) {
		anSobiSafe.setSaveDiv("I");
		return executeAnSobiSafe(anSobiSafe);
	}

	@Override
	public Map<String, Object> updateAnSobiSafe(AnSobiSafe anSobiSafe) {
		anSobiSafe.setSaveDiv("U");
		return executeAnSobiSafe(anSobiSafe);
	}

	@Override
	public Map<String, Object> deleteAnSobiSafe(AnSobiSafe anSobiSafe) {
		anSobiSafe.setSaveDiv("D");
		return executeAnSobiSafe(anSobiSafe);
	}
	
	private Map<String, Object> executeAnSobiSafe(AnSobiSafe anSobiSafe) {
		return repo.executeSaveAnSobiSafe(
				anSobiSafe.getSaveDiv(),
				anSobiSafe.getAreaCode(),
				anSobiSafe.getAnzCuCode(),
				anSobiSafe.getAnzSno(),
				anSobiSafe.getAnzDate(),
				anSobiSafe.getAnzSwCode(),
				anSobiSafe.getAnzSwName(),
				anSobiSafe.getAnzLpKg01(),
				anSobiSafe.getAnzLpKg02(),
				anSobiSafe.getAnzItem1(),
				anSobiSafe.getAnzItem1Sub(),
				anSobiSafe.getAnzItem1Text(),
				anSobiSafe.getAnzItem2(),
				anSobiSafe.getAnzItem2Sub(),
				anSobiSafe.getAnzItem3(),
				anSobiSafe.getAnzItem3Sub(),
				anSobiSafe.getAnzItem3Text(),
				anSobiSafe.getAnzItem4(),
				anSobiSafe.getAnzItem4Sub(),
				anSobiSafe.getAnzItem5(),
				anSobiSafe.getAnzItem5Sub(),
				anSobiSafe.getAnzItem5Text(),
				anSobiSafe.getAnzItem6(),
				anSobiSafe.getAnzItem6Sub(),
				anSobiSafe.getAnzItem7(),
				anSobiSafe.getAnzItem7Sub(),
				anSobiSafe.getAnzItem8(),
				anSobiSafe.getAnzItem8Sub(),
				anSobiSafe.getAnzItem8Text(),
				anSobiSafe.getAnzItem9(),
				anSobiSafe.getAnzItem9Sub(),
				anSobiSafe.getAnzItem9Text1(),
				anSobiSafe.getAnzItem9Text2(),
				anSobiSafe.getAnzItem10(),
				anSobiSafe.getAnzItem10Text1(),
				anSobiSafe.getAnzItem10Text2(),
				anSobiSafe.getAnzCuConfirm(),
				anSobiSafe.getAnzCuConfirmTel(),
				anSobiSafe.getAnzSignYn(),
				anSobiSafe.getGpsX(),
				anSobiSafe.getGpsY(),
				anSobiSafe.getAnzUserId());
	}
}
