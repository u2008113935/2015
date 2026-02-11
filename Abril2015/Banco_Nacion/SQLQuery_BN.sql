SELECT 
	STUFF('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@', 1, len ( left (replace(NOMBRE_CLIENTE,',',''),35) ), 
				left (replace(NOMBRE_CLIENTE,',',''),35)  )
	,len ( STUFF('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@', 1, len (replace(NOMBRE_CLIENTE,',','')), 
				left (replace(NOMBRE_CLIENTE,',',''),35)  )  )
	,len('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@')
	
FROM BN


SELECT 
		
	COD_PRESTAMO
	, STUFF('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@', 1, len (replace(NOMBRE_CLIENTE,',','')), 
				left (replace(NOMBRE_CLIENTE,',',''),35)  )	
	, STUFF('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@', 1, len (replace(NOMBRE_CLIENTE,',','')), 
				left (replace(NOMBRE_CLIENTE,',',''),35)  )		
	--REPLACE(LEFT(DIRECCION,35),'.','') 
	--CASE WHEN DOC_IDENT LIKE '%DOC%NACIONAL%IDEN%' THEN 'DNI'
	--WHEN DOC_IDENT LIKE '%REG%UNICO%CONT%' THEN 'RUC'
	--WHEN DOC_IDENT LIKE '%CARNET%EXTRANJERIA%' THEN 'CE'
	--END
	--) AS 'TEXT'
FROM BN