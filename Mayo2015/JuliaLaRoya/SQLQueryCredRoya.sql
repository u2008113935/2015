 Select * from creditosroya
 drop table creditosroya


--CURSOR COMPLETANDO CODIGO SBS de la tabla clientes
		Declare @nombre varchar(300), @cCodCliente varchar(20) --@codcre varchar(20)
		Declare cCursor95 CURSOR FOR
			select rtrim(NomClientes) from creditosroya
		OPEN cCursor95
		FETCH cCursor95 into @nombre
		WHILE (@@FETCH_STATUS=0)
		BEGIN
		  set @cCodCliente = (select cCodCliente
						   from [HYO00409\HISTORICO].CMACHYOCLI_201503.DBO.[CLIMCLIENTES]   
						   where cNomCliente = @nombre)				  

		  Update creditosroya 			 										
		  Set cCodCliente = @cCodCliente
		  where NomClientes = @nombre		  	    	
		  
		FETCH cCursor95 INTO @nombre
		END
		CLOSE cCursor95
		DEALLOCATE cCursor95
------------------------------------------------------------------------------------

select cCodCliente, cNomCliente
from [HYO00409\HISTORICO].CMACHYOCLI_201503.DBO.[CLIMCLIENTES]   
where cNomCliente like '%RAMIREZ%PERALES%VIRGINIA%'                                                      

107016185268	OSCCO HUAMAN, JUAN      107004101005273737	VIGENTE	AG. PERENE                                   
107016320861	CHAGUA TORRES, HECTOR RAUL 107004101005292966	VIGENTE	AG. PERENE

107004101005205544	VIGENTE	AG. PERENE


 Select * from creditosroya where cCodCliente ='107018001302'
 Select * from creditosroya where sec='50'

 select cCodCliente, count(cCodCliente) from creditosroya 
group by cCodCliente
having count(cCodCliente) > 1
107016185268	2
107018001302	2

 /*
 Update creditosroya
 Set cCodCliente = '107017101100', NomClientes = 'ESTRADA GARCIA, WUILDER WUILIAN'
 where sec='2'
 */

 Select * from creditosroya
-- delete from creditosroya where cCodCliente is not null

 ALTER table creditosroya
 add cEstado varchar(20)

 ALTER table creditosroya
 add Ofina varchar(50) 
----------------------------------------------------------------------------------------- 
--CURSOR COMPLETANDO CODIGO SBS de la tabla clientes
		Declare @cCodCliente1 varchar(20) , @codcre varchar(20), @cEstado varchar(20)
		,@Ofina varchar(50) 
		Declare cCursor95 CURSOR FOR
			--select cCodCliente from creditosroya
			select cCodCtaCred from creditosroya
		OPEN cCursor95
		FETCH cCursor95 into @codcre--@cCodCliente1
		WHILE (@@FETCH_STATUS=0)
		BEGIN
			/*
		  set @codcre = (select A.cCodCtaCre 
						from [HYO00409\HISTORICO].SOFCMACHYO_201503.DBO.[KPYMCreConven] A
							inner join [HYO00409\HISTORICO].SOFCMACHYO_201503.DBO.[GENMCRECLI] B 
								ON B.cCodCtaCre = A.cCodCtaCre  
							INNER JOIN [HYO00409\HISTORICO].CMACHYOCLI_201503.dbo.[CLIMCLIENTES] C 
								ON B.cCodCliente = C.cCodCliente
							where B.cCodCliente = @cCodCliente1 
								AND A.cEstCreCon in ('F','I','H'))
			*/
			
		  set @cEstado = (select E.cDescriEst 
						  from [HYO00409\HISTORICO].SOFCMACHYO_201503.DBO.[KPYMCreConven] A
							inner join [HYO00409\HISTORICO].SOFCMACHYO_201503.DBO.[GENMCRECLI] B 
								ON B.cCodCtaCre = A.cCodCtaCre  
							INNER JOIN [HYO00409\HISTORICO].CMACHYOCLI_201503.dbo.[CLIMCLIENTES] C 
								ON B.cCodCliente = C.cCodCliente
							INNER JOIN [HYO00409\HISTORICO].SOFCMACHYO_201503.DBO.[KPYTEstCreCon] E 
		    					ON E.cEstCreCon = A.cEstCreCon
							where A.cCodCtaCre = @codcre 
								)
		  set @Ofina = (select O.cDesOficin 
						  from [HYO00409\HISTORICO].SOFCMACHYO_201503.DBO.[KPYMCreConven] A
							inner join [HYO00409\HISTORICO].SOFCMACHYO_201503.DBO.[GENMCRECLI] B 
								ON B.cCodCtaCre = A.cCodCtaCre  
							INNER JOIN [HYO00409\HISTORICO].CMACHYOCLI_201503.dbo.[CLIMCLIENTES] C 
								ON B.cCodCliente = C.cCodCliente
							INNER JOIN [HYO00409\HISTORICO].SOFCMACHYO_201503.DBO.[GENTOficinas] O
								ON A.cCodOficin = O.cCodOficin
							where A.cCodCtaCre = @codcre 
								)	
			
		  /*
		  Update creditosroya 			 										
		  Set cCodCtaCred = @codcre
		  where cCodCliente = @cCodCliente1		  	    	
		  */
		  Update creditosroya 			 										
		  Set cEstado = @cEstado
		  where cCodCtaCred = @codcre	

		  Update creditosroya 			 										
		  Set Ofina = @Ofina
		  where cCodCtaCred = @codcre	
		  
		FETCH cCursor95 INTO @codcre--@cCodCliente1
		END
		CLOSE cCursor95
		DEALLOCATE cCursor95
------------------------------------------------------------------------------------

select top 1 * from  [HYO00409\HISTORICO].SOFCMACHYO_201503.DBO.[GENMCRECLI] CLI 
				ON CLI.cCodCtaCre = A.cCodCtaCre

select * from creditosroya where cCodCtaCred is null
/*
107040103783
cCodCtaCre	cDescriEst
107004101005202290	CANCELADO
*/

Update creditosroya
Set cCodCtaCred = '107004101005202290'
Where cCodCliente='107040103783'

select cCodCtaCred, count(cCodCtaCred) from creditosroya 
group by cCodCtaCred
having count(cCodCtaCred) > 1

select * from creditosroya where cCodCtaCred in ('107004101005399786')
107004101005399786	107018410940	TRINIDAD FARFAN, EFRAIN EMILIO
					107014476072	CASACHAHUA VALDIVIA, JAIME
		107004101005750468	VIGENTE	AG. PERENE
		107004101005195944	JUDICIAL	AG. PERENE

	select A.cCodCtaCre, E.cDescriEst,O.cDesOficin   
	from [HYO00409\HISTORICO].SOFCMACHYO_201503.DBO.[KPYMCreConven] A
		inner join [HYO00409\HISTORICO].SOFCMACHYO_201503.DBO.[GENMCRECLI] B 
			ON B.cCodCtaCre = A.cCodCtaCre  
		INNER JOIN [HYO00409\HISTORICO].CMACHYOCLI_201503.dbo.[CLIMCLIENTES] C 
			ON B.cCodCliente = C.cCodCliente
		INNER JOIN [HYO00409\HISTORICO].SOFCMACHYO_201503.DBO.[KPYTEstCreCon] E  
		    ON E.cEstCreCon = A.cEstCreCon
		INNER JOIN [HYO00409\HISTORICO].SOFCMACHYO_201503.DBO.[GENTOficinas] O
			ON A.cCodOficin = O.cCodOficin
		where B.cCodCliente = '107014476072' and cDesOficin = 'AG. PERENE'--@cCodCliente1  
			--AND A.cEstCreCon = 'F'

select * from creditosroya where cEstReprogramado = 'N'

------------------------------------------***********************

 Select * from creditosroya02

 --CURSOR COMPLETANDO CODIGO SBS de la tabla clientes
		Declare @CodigoCredito varchar(20), @FecDes date		
		Declare cCursor95 CURSOR FOR
			select CodigoCredito from creditosroya02
		OPEN cCursor95
		FETCH cCursor95 into @CodigoCredito
		WHILE (@@FETCH_STATUS=0)
		BEGIN			
			
		  set @FecDes = (select A.dFecDesCre 
						  from [HYO00409\HISTORICO].SOFCMACHYO_201503.DBO.[KPYMCreConven] A
							inner join [HYO00409\HISTORICO].SOFCMACHYO_201503.DBO.[GENMCRECLI] B 
								ON B.cCodCtaCre = A.cCodCtaCre  
							INNER JOIN [HYO00409\HISTORICO].CMACHYOCLI_201503.dbo.[CLIMCLIENTES] C 
								ON B.cCodCliente = C.cCodCliente							
							where A.cCodCtaCre = @CodigoCredito
								)			
		
		  Update creditosroya02 			 										
		  Set FechaDesembolso = @FecDes
		  where CodigoCredito = @CodigoCredito	
		  
		FETCH cCursor95 INTO @CodigoCredito
		END
		CLOSE cCursor95
		DEALLOCATE cCursor95
------------------------------------------------------------------------------------

select CodigoCredito, count(CodigoCredito) from creditosroya02 
group by CodigoCredito
having count(CodigoCredito) > 1

select * from creditosroya02  where CodigoCredito ='107004101005205544'

select * from creditosroya02  where EstadoRepro = 'N'