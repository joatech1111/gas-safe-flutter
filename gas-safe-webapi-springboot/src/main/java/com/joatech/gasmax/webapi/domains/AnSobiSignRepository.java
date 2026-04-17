package com.joatech.gasmax.webapi.domains;

import java.util.Optional;

/*
 * 서명
 */
public class AnSobiSignRepository extends GasMaxRepository {

	public AnSobiSignRepository(String dbHostname, int dbPortNumber, String dbName, String dbUsername,
			String dbPassword) {
		super(dbHostname, dbPortNumber, dbName, dbUsername, dbPassword);
		init();
	}

	/*
	 * todo: 서명 조회(SELECT * FROM AnSobi_Sign)
	 *  * todo: 서명 조회(SELECT * FROM AnSobi_Sign)
	 */
	public Optional<AnSobiSign> findByAreaCodeAndAnzCuCodeAndAnzSno(String areaCode, String anzCuCode, String anzSno) {

		String queryString = "SELECT * FROM ANSobi_Sign WHERE Area_Code = ? AND ANZ_Cu_Code = ? AND ANZ_Sno = ?";

		Optional<AnSobiSign> optAnSobiSign = null;
		try {
			optAnSobiSign = jdbcTemplate.queryForObject(
	        		queryString,
	                (rs, rowNum) -> {
	                	AnSobiSign anSobiSign = new AnSobiSign();
	                	anSobiSign.setAreaCode(rs.getString("Area_Code"));
	                	anSobiSign.setAnzCuCode(rs.getString("ANZ_Cu_Code"));
	                	anSobiSign.setAnzSno(rs.getString("ANZ_Sno"));
	                	anSobiSign.setAnzSign(rs.getString("ANZ_Sign"));
	                	anSobiSign.setAnzId(rs.getString("ANZ_ID"));
	                	anSobiSign.setAnzDate(rs.getString("ANZ_DATE"));

	                	return Optional.of(anSobiSign);
	                },
	                areaCode,
	                anzCuCode,
	                anzSno
	        );
		}
		catch (Exception ex) {

		}

		return optAnSobiSign;
	}

	public int findCountByAreaCodeAndAnzCuCodeAndAnzSno(String areaCode, String anzCuCode, String anzSno) {

		String queryString = "SELECT COUNT(*) FROM ANSobi_Sign WHERE Area_Code = ? AND ANZ_Cu_Code = ? AND ANZ_Sno = ?";

        int count = 0;
        try {
	        count = jdbcTemplate.queryForObject(
	        		queryString,
	        		new Object[] {
	        			areaCode,
	        			anzCuCode,
	        			anzSno
	                },
	        		Integer.class
	        );
        }
        catch (Exception ex) {

        }

	    return count;
	}

	public String findSignByAreaCodeAndAnzCuCodeAndAnzSno(String areaCode, String anzCuCode, String anzSno) {

		String queryString = "SELECT ANZ_Sign FROM ANSobi_Sign WHERE Area_Code = ? AND ANZ_Cu_Code = ? AND ANZ_Sno = ?";
		String sign = "";

		try {
			sign = jdbcTemplate.queryForObject(
	        		queryString,
	        		new Object[] {
	        			areaCode,
	        			anzCuCode,
	        			anzSno
	                },
	        		String.class
	        );
		}
		catch (Exception ex) {

		}

		return sign;
	}

	public int saveAnSobiSign(String areaCode, String anzCuCode, String anzSno, String anzSign, String anzId, String anzDate) {

		String queryString = "";
		int rows = 0;

		int count = findCountByAreaCodeAndAnzCuCodeAndAnzSno(areaCode, anzCuCode, anzSno);

		if (count == 0) {
			queryString = "INSERT INTO ANSobi_Sign (Area_Code, ANZ_Cu_Code, ANZ_Sno, ANZ_Sign, ANZ_ID, ANZ_DATE) VALUES (?, ?, ?, ?, ?, ?) ";
	        rows = jdbcTemplate.update(
	        		queryString,
	                areaCode,
	                anzCuCode,
	                anzSno,
	                anzSign,
	                anzId,
	                anzDate
	        );
		}
		else {
			queryString = "UPDATE ANSobi_Sign SET ANZ_Sign = ?, ANZ_ID = ?, ANZ_DATE = ? WHERE Area_Code = ? AND ANZ_Cu_Code = ? AND ANZ_Sno = ?";
	        rows = jdbcTemplate.update(
	        		queryString,
	                anzSign,
	                anzId,
	                anzDate,
	                areaCode,
	                anzCuCode,
	                anzSno
	        );
		}

        return rows;
	}



	public int deleteAnSobiSign(String areaCode, String anzCuCode, String anzSno) {

		String queryString = "";
		int rows = 0;

		queryString = "DELETE FROM ANSobi_Sign WHERE Area_Code = ? AND ANZ_Cu_Code = ? AND ANZ_Sno = ?";
        rows = jdbcTemplate.update(
        		queryString,
                areaCode,
                anzCuCode,
                anzSno
        );

        return rows;
	}

}
