package com.joatech.gasmax.webapi.services;

import java.util.List;
import java.util.Map;
import com.joatech.gasmax.webapi.domains.AnSobiTank;
import com.joatech.gasmax.webapi.domains.AnSobiTankRepository;

/*
 * 저장탱크 안전점검표 Select View(탱크 점검 Select)
 */
public class AnSobiTankService implements IAnSobiTankService {
	
	private AnSobiTankRepository repo;
	
	public AnSobiTankService(String dbHostname, int dbPortNumber, String dbName, String dbUsername, String dbPassword) {
		repo = new AnSobiTankRepository(dbHostname, dbPortNumber, dbName, dbUsername, dbPassword);
	}
	
	public void close() {
		repo.close();
	}

	@Override
	public List<Map<String, Object>> getAnSobiTankServiceBy(String areaCode, String anzCuCode, String anzSno) {

		return repo.findAnSobiTankBy(areaCode, anzCuCode, anzSno);
	}

	@Override
	public List<Map<String, Object>> getLastAnSobiTankServiceBy(String areaCode, String anzCuCode) {

		return repo.findLastAnSobiTankBy(areaCode, anzCuCode);
	}

	/*
	 * AddNew
	 */
	@Override
	public Map<String, Object> addNewAnSobiTank(AnSobiTank anSobiTank) {
		anSobiTank.setSaveDiv("I");
		return executeAnSobiTank(anSobiTank);
	}

	/*
	 * Update
	 */
	@Override
	public Map<String, Object> updateAnSobiTank(AnSobiTank anSobiTank) {
		anSobiTank.setSaveDiv("U");
		return executeAnSobiTank(anSobiTank);
	}

	/*
	 * Delete
	 */
	@Override
	public Map<String, Object> deleteAnSobiTank(AnSobiTank anSobiTank) {
		anSobiTank.setSaveDiv("D");
		return executeAnSobiTank(anSobiTank);
	}
	
	private Map<String, Object> executeAnSobiTank(AnSobiTank anSobiTank) {
		return repo.executeSaveAnSobiTank(
				anSobiTank.getSaveDiv(),
				anSobiTank.getAreaCode(),
				anSobiTank.getAnzCuCode(),
				anSobiTank.getAnzSno(),
				anSobiTank.getAnzDate(),
				anSobiTank.getAnzSwCode(),
				anSobiTank.getAnzSwName(),
				anSobiTank.getAnzTankKg01(),
				anSobiTank.getAnzTankKg02(),
				anSobiTank.getAnzTank01(),
				anSobiTank.getAnzTank01Bigo(),
				anSobiTank.getAnzTank02(),
				anSobiTank.getAnzTank02Bigo(),
				anSobiTank.getAnzTank03(),
				anSobiTank.getAnzTank03Bigo(),
				anSobiTank.getAnzTank04(),
				anSobiTank.getAnzTank04Bigo(),
				anSobiTank.getAnzTank05(),
				anSobiTank.getAnzTank05Bigo(),
				anSobiTank.getAnzTank06(),
				anSobiTank.getAnzTank06Bigo(),
				anSobiTank.getAnzTank07(),
				anSobiTank.getAnzTank07Bigo(),
				anSobiTank.getAnzTank08(),
				anSobiTank.getAnzTank08Bigo(),
				anSobiTank.getAnzTank09(),
				anSobiTank.getAnzTank09Bigo(),
				anSobiTank.getAnzcheckItem10(),
				anSobiTank.getAnzTank10(),
				anSobiTank.getAnzTank10Bigo(),	
				anSobiTank.getAnzcheckItem11(),
				anSobiTank.getAnzTank11(),
				anSobiTank.getAnzTank11Bigo(),
				anSobiTank.getAnzcheckItem12(),
				anSobiTank.getAnzTank12(),
				anSobiTank.getAnzTank12Bigo(),
				anSobiTank.getAnzTankSwBigo1(),
				anSobiTank.getAnzTankSwBigo2(),
				anSobiTank.getAnzCustName(),
				anSobiTank.getAnzSignYn(),
				anSobiTank.getAnzCuConfirm(),
				anSobiTank.getAnzCuConfirmTel(),
				anSobiTank.getGpsX(),
				anSobiTank.getGpsY(),
				anSobiTank.getAnzUserId());
	}

}
