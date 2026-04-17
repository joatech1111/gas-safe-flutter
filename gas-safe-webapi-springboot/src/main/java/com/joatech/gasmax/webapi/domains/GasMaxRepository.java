package com.joatech.gasmax.webapi.domains;

import java.sql.Connection;
import java.sql.SQLException;

import javax.annotation.PostConstruct;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.datasource.DriverManagerDataSource;

import com.joatech.gasmax.webapi.configurations.GasMaxConfig;
import com.joatech.gasmax.webapi.defines.GasMaxConst;

public class GasMaxRepository {
	
	private String dbHostname;
	private int dbPortNumber;
	private String dbName;
	private String dbUsername;
	private String dbPassword;
	
	protected JdbcTemplate jdbcTemplate;
	
	@Autowired
	protected GasMaxConfig gasMaxConfig;

	public GasMaxRepository(String dbHostname, int dbPortNumber, String dbName, String dbUsername, String dbPassword) {
		this.dbHostname = dbHostname;
		this.dbPortNumber = dbPortNumber;
		this.dbName = dbName;
		this.dbUsername = dbUsername;
		this.dbPassword = dbPassword;
	}
	
	@PostConstruct
	public void init() {
		connect();
	}

	public void connect() {

		String connUrl = String.format("jdbc:jtds:sqlserver://%s:%d;databaseName=%s", dbHostname, dbPortNumber, dbName);
		
		DriverManagerDataSource dataSource = new DriverManagerDataSource();
		dataSource.setDriverClassName(GasMaxConst.MSSQL_JDBC_DRIVER_CLASS_NAME);
		dataSource.setUrl(connUrl);
		dataSource.setUsername(dbUsername);
		dataSource.setPassword(dbPassword);

		jdbcTemplate = new JdbcTemplate(dataSource);
	}

	public void close() {
		try {
			Connection connection = jdbcTemplate.getDataSource().getConnection();
			connection.close();
		} catch (SQLException e) {
			e.printStackTrace();
		}
	}

}
