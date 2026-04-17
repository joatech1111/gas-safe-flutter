package com.joatech.gasmax.webapi.services;

import java.util.Optional;

import com.joatech.gasmax.webapi.domains.AnSobiSign;
import com.joatech.gasmax.webapi.domains.AnSobiSignRepository;

public class AnSobiSignService implements IAnSobiSignService {

	private AnSobiSignRepository repo;

	public AnSobiSignService(String dbHostname, int dbPortNumber, String dbName, String dbUsername, String dbPassword) {
		repo = new AnSobiSignRepository(dbHostname, dbPortNumber, dbName, dbUsername, dbPassword);
	}

	public void close() {
		repo.close();
	}

	@Override
	public Optional<AnSobiSign> getAnSobiSignByAreaCodeAndAnzCuCodeAndAnzSno(String areaCode, String anzCuCode, String anzSno) {
		return repo.findByAreaCodeAndAnzCuCodeAndAnzSno(areaCode, anzCuCode, anzSno);
	}

	@Override
	public String getSignByAreaCodeAndAnzCuCodeAndAnzSno(String areaCode, String anzCuCode, String anzSno) {
		return repo.findSignByAreaCodeAndAnzCuCodeAndAnzSno(areaCode, anzCuCode, anzSno);
	}

	@Override
	public int getCountByAreaCodeAndAnzCuCodeAndAnzSno(String areaCode, String anzCuCode, String anzSno) {
		return repo.findCountByAreaCodeAndAnzCuCodeAndAnzSno(areaCode, anzCuCode, anzSno);
	}

	@Override
	public int saveAnSobiSign(AnSobiSign anSobiSign) {
		return repo.saveAnSobiSign(
				anSobiSign.getAreaCode(),
				anSobiSign.getAnzCuCode(),
				anSobiSign.getAnzSno(),
				anSobiSign.getAnzSign(),
				anSobiSign.getAnzId(),
				anSobiSign.getAnzDate());
	}



	@Override
	public int deleteAnSobiSign(AnSobiSign anSobiSign) {
		return repo.deleteAnSobiSign(
				anSobiSign.getAreaCode(),
				anSobiSign.getAnzCuCode(),
				anSobiSign.getAnzSno());
	}

}
