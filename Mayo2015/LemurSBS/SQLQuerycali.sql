select * from EstFinanDic2014

drop table EstFinanDic2014

SELECT * into EstFinanDic201402 FROM (select * from EstFinanDic2014) as tmp99


--cNomCliente	cNomCorCli
--LOPEZ ORE, KARINA	KARINA LOPEZ ORE

--CURSOR COMPLETANDO CODIGO SBS de la tabla clientes
		Declare @nombre varchar(100), @codsbs1 varchar(10), @cCodCliente varchar(20) 
		Declare cCursor95 CURSOR FOR
			select NomCliente from EstFinanDic2014
		OPEN cCursor95
		FETCH cCursor95 into @nombre
		WHILE (@@FETCH_STATUS=0)
		BEGIN
		  set @codsbs1 = (select cCodSbs            
						   from [HYO00409\HISTORICO].CMACHYOCLI_201503.DBO.[CLIMCLIENTES]   
						   where cNomCliente = @nombre)				  

		set @cCodCliente = (select cCodCliente
						   from [HYO00409\HISTORICO].CMACHYOCLI_201503.DBO.[CLIMCLIENTES]   
						   where cNomCliente = @nombre)	

		  Update EstFinanDic2014 			 										
		  Set cCodSBS = @codsbs1
		  where NomCliente = @nombre		  

		  Update EstFinanDic2014 			 										
		  Set cCliente = @cCodCliente
		  where NomCliente = @nombre		    	
		  
		FETCH cCursor95 INTO @nombre
		END
		CLOSE cCursor95
		DEALLOCATE cCursor95
------------------------------------------------------------------------------------

select * from EstFinanDic2014

alter table EstFinanDic2014
add CaliDic2013 varchar(20)

alter table EstFinanDic2014
add DeudaDic2013 money

select top 1 *  from [HYO00401].CRICMACHYO.DBO.urirccsal_3 
SELECT TOP 1 CMESPRO  from [HYO00401].CRICMACHYO.DBO.urirccmae_3 --DIC2014
SELECT TOP 1 CMESPRO  from [HYO00401].CRICMACHYO.DBO.urirccmae_4 --NOV2014
SELECT TOP 1 CMESPRO  from [HYO00401].CRICMACHYO.DBO.urirccmae_5 --OCT2014
SELECT TOP 1 CMESPRO  from [HYO00401].CRICMACHYO.DBO.urirccmae_6 --SET2014
SELECT TOP 1 CMESPRO  from [HYO00401].CRICMACHYO.DBO.urirccmae_7 --AGO2014
SELECT TOP 1 CMESPRO  from [HYO00401].CRICMACHYO.DBO.urirccmae_8 --JUL2014
SELECT TOP 1 CMESPRO  from [HYO00401].CRICMACHYO.DBO.urirccmae_9 --JUN2014
SELECT TOP 1 CMESPRO  from [HYO00401].CRICMACHYO.DBO.urirccmae_10 --MAYO2014
SELECT TOP 1 CMESPRO  from [HYO00401].CRICMACHYO.DBO.urirccmae_11 --ABR2014
SELECT TOP 1 CMESPRO  from [HYO00401].CRICMACHYO.DBO.urirccmae_12 --MAR2014
SELECT TOP 1 CMESPRO  from [HYO00401].CRICMACHYO.DBO.urirccmae_13 --FEB2014
SELECT TOP 1 CMESPRO  from [HYO00401].CRICMACHYO.DBO.urirccmae_14 --ENE2014
SELECT TOP 1 CMESPRO  from [HYO00402].CRICMACHYO_DIARIO.DBO.urirccmae_15 --DIC2013
SELECT TOP 1 *  from [HYO00402].CRICMACHYO_DIARIO.DBO.urirccmae_15 --DIC2013



--*********************************INDEXANDO****************************************************
CREATE NONCLUSTERED INDEX EstFinanDic2014_cCodSBS_IXN ON EstFinanDic2014(cCodSBS)

--------------------****************************************************************************
	--CURSOR 
		Declare @codsbs varchar(10),
		@CaliEne2014 varchar(20),@DeudaEne2014 money,
		@CaliFeb2014 varchar(20),@DeudaFeb2014 money, 
		@CaliMar2014 varchar(20),@DeudaMar2014 money,
		@CaliAbr2014 varchar(20),@DeudaAbr2014 money,
		@CaliMay2014 varchar(20),@DeudaMay2014 money, 
		@CaliJun2014 varchar(20),@DeudaJun2014 money,
		@CaliJul2014 varchar(20),@DeudaJul2014 money,
		@CaliAgo2014 varchar(20),@DeudaAgo2014 money, 
		@CaliSet2014 varchar(20),@DeudaSet2014 money,
		@CaliOct2014 varchar(20),@DeudaOct2014 money,
		@CaliNov2014 varchar(20),@DeudaNov2014 money,
		@CaliDic2014 varchar(20), @DeudaDic2014 money,
		@CaliDic2013 varchar(20), @DeudaDic2013 money

		Declare cCursor98 CURSOR FOR
			select cCodSBS from EstFinanDic2014 
		OPEN cCursor98
		FETCH cCursor98 into @codsbs
		WHILE (@@FETCH_STATUS=0)
		BEGIN
			--Dic2013
			 set @CaliDic2013 = (select CCLAFIN
					   from  [HYO00402].CRICMACHYO_DIARIO.DBO.urirccmae_15
					   where CCODSBS = @codsbs)		
		

			 set @DeudaDic2013 = (Select sum(NSALDOS)
					from  [HYO00402].CRICMACHYO_DIARIO.DBO.urirccsal_15
					where CCODSBS = @codsbs and left(CCTACON,4) 
						in ('1411','1413','1414','1415','1416','1421','1423','1424','1425','1426'))

		  Update EstFinanDic2014 			 										
		  Set CaliDic2013 = @CaliDic2013
		  where cCodSBS = @codsbs		  

		  Update EstFinanDic2014 			 										
		  Set DeudaDic2013 = @DeudaDic2013
		  where cCodSBS = @codsbs

		  /* 
		  --Dic2014
			
		  set @CaliDic2014 = (select CCLAFIN
					   from  [HYO00401].CRICMACHYO.DBO.urirccmae_3
					   where CCODSBS = @codsbs)		
		

		 set @DeudaDic2014 = (Select sum(NSALDOS)
					from  [HYO00401].CRICMACHYO.DBO.urirccsal_3  
					where CCODSBS = @codsbs and left(CCTACON,4) 
						in ('1411','1413','1414','1415','1416','1421','1423','1424','1425','1426'))

		  Update EstFinanDic2014 			 										
		  Set CaliDic2014 = @CaliDic2014
		  where cCodSBS = @codsbs		  

		  Update EstFinanDic2014 			 										
		  Set DeudaDic2014 = @DeudaDic2014
		  where cCodSBS = @codsbs		  

		  --Nov2014
		  set @CaliNov2014 = (select CCLAFIN
					   from  [HYO00401].CRICMACHYO.DBO.urirccmae_4
					   where CCODSBS = @codsbs)		
		

		 set @DeudaNov2014 = (Select sum(NSALDOS)
					from  [HYO00401].CRICMACHYO.DBO.urirccsal_4 
					where CCODSBS = @codsbs and left(CCTACON,4) 
						in ('1411','1413','1414','1415','1416','1421','1423','1424','1425','1426'))

		  Update EstFinanDic2014 			 										
		  Set CaliNov2014 = @CaliNov2014
		  where cCodSBS = @codsbs		  

		  Update EstFinanDic2014 			 										
		  Set DeudaNov2014 = @DeudaNov2014
		  where cCodSBS = @codsbs

		  --Oct2014
		  set @CaliOct2014 = (select CCLAFIN
					   from  [HYO00401].CRICMACHYO.DBO.urirccmae_5
					   where CCODSBS = @codsbs)		
		

		 set @DeudaOct2014 = (Select sum(NSALDOS)
					from  [HYO00401].CRICMACHYO.DBO.urirccsal_5  
					where CCODSBS = @codsbs and left(CCTACON,4) 
						in ('1411','1413','1414','1415','1416','1421','1423','1424','1425','1426'))

		  Update EstFinanDic2014 			 										
		  Set CaliOct2014 = @CaliOct2014
		  where cCodSBS = @codsbs		  

		  Update EstFinanDic2014 			 										
		  Set DeudaOct2014 = @DeudaOct2014
		  where cCodSBS = @codsbs
		 
		   
		  --Sep2014
		  set @CaliSet2014 = (select CCLAFIN
					   from  [HYO00401].CRICMACHYO.DBO.urirccmae_6
					   where CCODSBS = @codsbs)		
		

		 set @DeudaSet2014 = (Select sum(NSALDOS)
					from  [HYO00401].CRICMACHYO.DBO.urirccsal_6  
					where CCODSBS = @codsbs and left(CCTACON,4) 
						in ('1411','1413','1414','1415','1416','1421','1423','1424','1425','1426'))

		  Update EstFinanDic2014 			 										
		  Set CaliSet2014 = @CaliSet2014
		  where cCodSBS = @codsbs		  

		  Update EstFinanDic2014 			 										
		  Set DeudaSet2014 = @DeudaSet2014
		  where cCodSBS = @codsbs

		  --Ago2014
		  set @CaliAgo2014 = (select CCLAFIN
					   from  [HYO00401].CRICMACHYO.DBO.urirccmae_7
					   where CCODSBS = @codsbs)		
		

		 set @DeudaAgo2014 = (Select sum(NSALDOS)
					from  [HYO00401].CRICMACHYO.DBO.urirccsal_7  
					where CCODSBS = @codsbs and left(CCTACON,4) 
						in ('1411','1413','1414','1415','1416','1421','1423','1424','1425','1426'))

		  Update EstFinanDic2014 			 										
		  Set CaliAgo2014 = @CaliAgo2014
		  where cCodSBS = @codsbs		  

		  Update EstFinanDic2014 			 										
		  Set DeudaAgo2014 = @DeudaAgo2014
		  where cCodSBS = @codsbs		 
		 
		  --Jul2014
		  set @CaliJul2014 = (select CCLAFIN
					   from  [HYO00401].CRICMACHYO.DBO.urirccmae_8
					   where CCODSBS = @codsbs)		
		

		 set @DeudaJul2014 = (Select sum(NSALDOS)
					from  [HYO00401].CRICMACHYO.DBO.urirccsal_8  
					where CCODSBS = @codsbs and left(CCTACON,4) 
						in ('1411','1413','1414','1415','1416','1421','1423','1424','1425','1426'))

		  Update EstFinanDic2014 			 										
		  Set CaliJul2014 = @CaliJul2014
		  where cCodSBS = @codsbs		  

		  Update EstFinanDic2014 			 										
		  Set DeudaJul2014 = @DeudaJul2014
		  where cCodSBS = @codsbs
		  
		  --JUN 2014
		  set @CaliJun2014 = (select CCLAFIN
					   from  [HYO00401].CRICMACHYO.DBO.urirccmae_9
					   where CCODSBS = @codsbs)		
		

		 set @DeudaJun2014 = (Select sum(NSALDOS)
					from  [HYO00401].CRICMACHYO.DBO.urirccsal_9  
					where CCODSBS = @codsbs and left(CCTACON,4) 
						in ('1411','1413','1414','1415','1416','1421','1423','1424','1425','1426'))

		  Update EstFinanDic2014 			 										
		  Set CaliJun2014 = @CaliJun2014
		  where cCodSBS = @codsbs		  

		  Update EstFinanDic2014 			 										
		  Set DeudaJun2014 = @DeudaJun2014
		  where cCodSBS = @codsbs

		  --MAYO2014
		  set @CaliMay2014 = (select CCLAFIN
					   from  [HYO00401].CRICMACHYO.DBO.urirccmae_10
					   where CCODSBS = @codsbs)		
		

		 set @DeudaMay2014 = (Select sum(NSALDOS)
					from  [HYO00401].CRICMACHYO.DBO.urirccsal_10  
					where CCODSBS = @codsbs and left(CCTACON,4) 
						in ('1411','1413','1414','1415','1416','1421','1423','1424','1425','1426'))

		  Update EstFinanDic2014 			 										
		  Set CaliMay2014 = @CaliMay2014
		  where cCodSBS = @codsbs		  

		  Update EstFinanDic2014 			 										
		  Set DeudaMay2014 = @DeudaMay2014
		  where cCodSBS = @codsbs
		  
		  
		  --ABRIL 2014
		  set @CaliAbr2014 = (select CCLAFIN
					   from  [HYO00401].CRICMACHYO.DBO.urirccmae_11
					   where CCODSBS = @codsbs)		
		

		 set @DeudaAbr2014 = (Select sum(NSALDOS)
					from  [HYO00401].CRICMACHYO.DBO.urirccsal_11  
					where CCODSBS = @codsbs and left(CCTACON,4) 
						in ('1411','1413','1414','1415','1416','1421','1423','1424','1425','1426'))

		  Update EstFinanDic2014 			 										
		  Set CaliAbr2014 = @CaliAbr2014
		  where cCodSBS = @codsbs		  

		  Update EstFinanDic2014 			 										
		  Set DeudaAbr2014 = @DeudaAbr2014
		  where cCodSBS = @codsbs
		  
		  
		  --MARZO 2014
		  set @CaliMar2014 = (select CCLAFIN
					   from  [HYO00401].CRICMACHYO.DBO.urirccmae_12
					   where CCODSBS = @codsbs)		
		

		 set @DeudaMar2014 = (Select sum(NSALDOS)
					from  [HYO00401].CRICMACHYO.DBO.urirccsal_12  
					where CCODSBS = @codsbs and left(CCTACON,4) 
						in ('1411','1413','1414','1415','1416','1421','1423','1424','1425','1426'))

		  Update EstFinanDic2014 			 										
		  Set CaliMar2014 = @CaliMar2014
		  where cCodSBS = @codsbs		  

		  Update EstFinanDic2014 			 										
		  Set DeudaMar2014 = @DeudaMar2014
		  where cCodSBS = @codsbs
		  
		  
		  --FEB 2014
		  set @CaliFeb2014 = (select CCLAFIN
					   from  [HYO00401].CRICMACHYO.DBO.urirccmae_13
					   where CCODSBS = @codsbs)		
		

		 set @DeudaFeb2014 = (Select sum(NSALDOS)
					from  [HYO00401].CRICMACHYO.DBO.urirccsal_13  
					where CCODSBS = @codsbs and left(CCTACON,4) 
						in ('1411','1413','1414','1415','1416','1421','1423','1424','1425','1426'))

		  Update EstFinanDic2014 			 										
		  Set CaliFeb2014 = @CaliFeb2014
		  where cCodSBS = @codsbs		  

		  Update EstFinanDic2014 			 										
		  Set DeudaFeb2014 = @DeudaFeb2014
		  where cCodSBS = @codsbs
		 
		  --ENE 2014
		  set @CaliEne2014 = (select CCLAFIN
					   from  [HYO00401].CRICMACHYO.DBO.urirccmae_14
					   where CCODSBS = @codsbs)		
		

		 set @DeudaEne2014 = (Select sum(NSALDOS)
					from  [HYO00401].CRICMACHYO.DBO.urirccsal_14  
					where CCODSBS = @codsbs and left(CCTACON,4) 
						in ('1411','1413','1414','1415','1416','1421','1423','1424','1425','1426'))

		  Update EstFinanDic2014 			 										
		  Set CaliEne2014 = @CaliEne2014
		  where cCodSBS = @codsbs		  

		  Update EstFinanDic2014 			 										
		  Set DeudaEne2014 = @DeudaEne2014
		  where cCodSBS = @codsbs
		 */

		FETCH cCursor98 INTO @codsbs
		END
		CLOSE cCursor98
		DEALLOCATE cCursor98
------------------------------------------------------------------------------------

select Nomcliente, cCliente,cCodSBS,CaliEne2014,DeudaEne2014,CaliFeb2014,DeudaFeb2014,CaliMar2014
		,DeudaMar2014,CaliAbr2014,DeudaAbr2014,CaliMay2014,DeudaMay2014,CaliJun2014,DeudaJun2014
		,CaliJul2014,DeudaJul2014,CaliAgo2014,DeudaAgo2014,CaliSet2014,DeudaSet2014,CaliOct2014
		,DeudaOct2014,CaliNov2014,DeudaNov2014,CaliDic2014,DeudaDic2014
from EstFinanDic2014

select * from EstFinanDic2014 where CaliDic2014 is null or DeudaDic2014 is null
select * from EstFinanDic2014 where cCliente is null or cCodSBS is null

----calificacion 
select Nomcliente, cCliente,cCodSBS,CaliEne2014,DeudaEne2014,CaliFeb2014,DeudaFeb2014,CaliMar2014
		,DeudaMar2014,CaliAbr2014,DeudaAbr2014,CaliMay2014,DeudaMay2014,CaliJun2014,DeudaJun2014
		,CaliJul2014,DeudaJul2014,CaliAgo2014,DeudaAgo2014,CaliSet2014,DeudaSet2014,CaliOct2014
		,DeudaOct2014,CaliNov2014,DeudaNov2014,CaliDic2014,DeudaDic2014
from EstFinanDic2014

	--Update EstFinanDic2014
	--Set DeudaDic2014 = 0
	--Where DeudaDic2014 is null

	select * from EstFinanDic2014 order by Nomcliente



