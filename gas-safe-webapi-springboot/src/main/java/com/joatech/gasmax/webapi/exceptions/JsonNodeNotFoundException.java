package com.joatech.gasmax.webapi.exceptions;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

@ResponseStatus(HttpStatus.FORBIDDEN)
public class JsonNodeNotFoundException extends RuntimeException {

	private static final long serialVersionUID = 7385411666909729783L;
	private final Logger logger = LoggerFactory.getLogger(getClass());

	public JsonNodeNotFoundException(String exception) {
		super(exception);
		logger.error(this.getLocalizedMessage());
	}
}
