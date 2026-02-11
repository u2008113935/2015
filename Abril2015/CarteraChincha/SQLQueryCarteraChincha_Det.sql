SELECT top 5 Z.CDESQUECARF,* FROM HYO00410.SOFCMACHYO_RIESGOS.dbo.[URIHHisCartera] Z (NOLOCK)

(SELECT Z.CDESQUECARF , z.CCODFECMES , z.*
FROM HYO00410.SOFCMACHYO_RIESGOS.dbo.[URIHHisCartera] Z (NOLOCK) 
		--INNER JOIN chincha X  ON X.CODIGO_CLIENTE = Z.CCODCLIENTE
WHERE --CCODFECMES = '201503'  AND 
CCODCLIENTE = '107021243809' ) 

--DROP TABLE chincha
SELECT * from repchincha ch
--(752 row(s) affected)

select ch.*,isnull(r.CDESQUECARF,'NO REGISTRA')  AS 'RCC_MAR2014'
from repchincha ch
	LEFT join rcc r on r.CCODCLIENTE = ch.CODIGO_CLIENTE
	
select * from rcc

select * from repchincha WHERE NumCuota = '---'
/*
uPDATE chincha
set NumCuota = '---'
WHERE NumCuota = 'Nor'


CREATE NONCLUSTERED INDEX repchincha_CODIGO_CLIENTE_IXN ON repchincha(CODIGO_CLIENTE)

			ALTER TABLE chincha
			ADD RCC_OCT2014 VARCHAR(12)
			--RCC_FEB2014 VARCHAR(12) , RCC_MAR2014 VARCHAR(12) , RCC_ABR2014 VARCHAR(12) 			
			--RCC_MAY2014 VARCHAR(12), RCC_JUN2014 VARCHAR(12) , RCC_JUL2014 VARCHAR(12) , RCC_AGO2014 VARCHAR(12) 			
			--RCC_SET2014 VARCHAR(12), RCC_OCT2014 VARCHAR(12) , RCC_NOV2014 VARCHAR(12) , RCC_DIC2014 VARCHAR(12) 
			--RCC_ENE2015 VARCHAR(12) , RCC_FEB2015 VARCHAR(12) 

---------------*******CURSOR CLASIFICACION RCC****************----------------------------------
				Declare @ccodcliente varchar(12), @mar2015 char(12), @feb2015 char(12) , @ene2015 char(12)
				, @dic2014 char(12), @nov2014 char(12) ,@oct2014  char(12)
				/*
				 ,@set2014 char(12), @ago2014 char(12)
				, @jul2014 char(12), @jun2014 char(12), @may2014 char(12) ,@abr2014  char(12), @mar2014 char(12)
				, @feb2014 char(12)
				*/
				Declare cClienteRCC CURSOR FOR					
					SELECT CODIGO_CLIENTE
					FROM  chincha (NOLOCK) 
					
				OPEN cClienteRCC
				FETCH cClienteRCC into @ccodcliente
				WHILE (@@FETCH_STATUS=0)
				BEGIN		
					--SET @ccodcliente = '107010613779'--'107010614033'

					set @mar2015 = 
								(SELECT Z.CDESQUECARF FROM HYO00410.SOFCMACHYO_RIESGOS.dbo.[URIHHisCartera] Z (NOLOCK) 										
										WHERE CCODFECMES = '201503'
										AND CCODCLIENTE = @ccodcliente ) 	
					IF @mar2015 <> ''
					BEGIN		
								Update chincha
								Set RCC_MAR2015 = @mar2015
								WHERE CODIGO_CLIENTE = @ccodcliente
					END	
					ELSE IF @mar2015 IS NULL
					BEGIN
								Update chincha
								Set RCC_MAR2015 = 'NO REGISTRA'
								WHERE CODIGO_CLIENTE = @ccodcliente
					END			
					/*
					--feb2015
					set @feb2015 = 
								(SELECT Z.CDESQUECARF FROM HYO00410.SOFCMACHYO_RIESGOS.dbo.[URIHHisCartera] Z (NOLOCK) 										
										WHERE CCODFECMES = '201502'
										AND CCODCLIENTE = @ccodcliente ) 	
														
					IF @feb2015 <> ''
					BEGIN		
								Update chincha
								Set RCC_FEB2015 = @feb2015
								WHERE CODIGO_CLIENTE = @ccodcliente
					END	
					ELSE IF @feb2015 IS NULL
					BEGIN
								Update chincha
								Set RCC_FEB2015 = 'NO REGISTRA'
								WHERE CODIGO_CLIENTE = @ccodcliente
					END				

					--ENE2015
					set @ene2015 = 
								(SELECT Z.CDESQUECARF FROM HYO00410.SOFCMACHYO_RIESGOS.dbo.[URIHHisCartera] Z (NOLOCK) 										
										WHERE CCODFECMES = '201501'
										AND CCODCLIENTE = @ccodcliente ) 					
					IF @ene2015 <> ''
					BEGIN		
								Update chincha
								Set RCC_ENE2015 = @ene2015
								WHERE CODIGO_CLIENTE = @ccodcliente
					END
					ELSE IF @ene2015 IS NULL
					BEGIN
								Update chincha
								Set RCC_ENE2015 = 'NO REGISTRA'
								WHERE CODIGO_CLIENTE = @ccodcliente
					END								

					--DIC2014
					set @dic2014 = 
								(SELECT Z.CDESQUECARF FROM HYO00410.SOFCMACHYO_RIESGOS.dbo.[URIHHisCartera] Z (NOLOCK) 										
										WHERE CCODFECMES = '201412'
										AND CCODCLIENTE = @ccodcliente ) 					
					IF @dic2014 <> ''
					BEGIN		
								Update chincha
								Set RCC_DIC2014 = @dic2014
								WHERE CODIGO_CLIENTE = @ccodcliente
					END				
					ELSE IF @dic2014 IS NULL
					BEGIN
								Update chincha
								Set RCC_DIC2014 = 'NO REGISTRA'
								WHERE CODIGO_CLIENTE = @ccodcliente
					END		

					--NOV2014
					set @nov2014 = 
								(SELECT Z.CDESQUECARF FROM HYO00410.SOFCMACHYO_RIESGOS.dbo.[URIHHisCartera] Z (NOLOCK) 										
										WHERE CCODFECMES = '201411'
										AND CCODCLIENTE = @ccodcliente ) 					
					IF @nov2014 <> ''
					BEGIN		
								Update chincha
								Set RCC_NOV2014 = @nov2014
								WHERE CODIGO_CLIENTE = @ccodcliente
					END
					ELSE IF @nov2014 IS NULL
					BEGIN
								Update chincha
								Set RCC_NOV2014 = 'NO REGISTRA'
								WHERE CODIGO_CLIENTE = @ccodcliente
					END					

					--OCT2014
					set @oct2014 = 
								(SELECT Z.CDESQUECARF FROM HYO00410.SOFCMACHYO_RIESGOS.dbo.[URIHHisCartera] Z (NOLOCK) 										
										WHERE CCODFECMES = '201410'
										AND CCODCLIENTE = @ccodcliente ) 					
					IF @oct2014 <> ''
					BEGIN		
								Update chincha
								Set RCC_OCT2014 = @oct2014
								WHERE CODIGO_CLIENTE = @ccodcliente
					END				
					ELSE IF @oct2014 IS NULL
					BEGIN
								Update chincha
								Set RCC_OCT2014 = 'NO REGISTRA'
								WHERE CODIGO_CLIENTE = @ccodcliente
					END	
					*/				
				FETCH cClienteRCC INTO @ccodcliente
				END
				CLOSE cClienteRCC
				DEALLOCATE cClienteRCC				
				*/