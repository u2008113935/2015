	Select * from LIMASUR -- (20,226 row(s) affected)
	Select * from LIMANorte
	Select * from CentroOriente
	Select * from ZONACENTRO
	Select * from SELVACENTRAL

	------------------------------------------------------------------------------------
	
	--------------SOLO LIMA SUR-------------------------		
		Select * from MDESERV01 where Zona = 'ZONA LIMA SUR' and cCodOficin='024'
		-- (2,680 row(s) affected)
			Select count(CODIGO_Credito)
			from MDESERV01 
			group by CODIGO_Credito,Zona
			having count(CODIGO_Credito) = 1 and Zona = 'ZONA LIMA SUR' 

			Select count(CODIGO_Credito)
			from MDESERV01 
			where Zona = 'ZONA LIMA SUR' 

			Select * from LIMASUR 
			WHERE rtrim(CODIGO_Credito)  IN 
				(Select rtrim(CODIGO_Credito) from MDESERV01 ) 
			-- (17,783 row(s) affected)

	--------------SOLO CENTRO-------------------------
		select * from MDESERV01 where Zona = 'ZONA CENTRO' 
		ORDER BY CODIGO_CLIENTE

	--------------SOLO CENTRO ORIENTE-------------------------
		select * from MDESERV01 where Zona = 'ZONA CENTRO ORIENTE' 
		ORDER BY CODIGO_CLIENTE

	--------------SOLO SELVA CENTRAL-------------------------
		select * from MDESERV01 where Zona = 'ZONA SELVA CENTRAL' 
		ORDER BY CODIGO_CLIENTE

	--------------SOLO LIMA NORTE-------------------------
		select * from MDESERV01 where Zona = 'ZONA LIMA NORTE' 
		ORDER BY CODIGO_CLIENTE

