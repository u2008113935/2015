select * from limanorte
--drop table limanorte
select len(COD_SBS1) from limanorte

--*********************************INDEXANDO****************************************************
CREATE NONCLUSTERED INDEX limanorte_CODIGO_CLIENTE_IXN ON limanorte(CODIGO_CLIENTE)
CREATE NONCLUSTERED INDEX limanorte_COD_SBS1_IXN ON limanorte(COD_SBS1)
CREATE NONCLUSTERED INDEX limanorte_CODIGO_CREDITO_IXN ON limanorte(CODIGO_CREDITO)
--------------------****************************************************************************

select A.CMESPRO, A.CCODSBS, A.CNUDOCI, A.CCLAFIN 
from HYO00410.URIESGOS.dbo.[URIRCCMAE808_FEB15] A (NOLOCK)
where A.ccodsbs = '0086863359'

select B.CMESPRO,B.CCODSBS,B.CNUDOCI,B.CCLAFIN 
from HYO00410.URIESGOS.dbo.[URIRCCMAE808_ENE15] B (NOLOCK)
where B.ccodsbs = '0086863359'

select C.CMESPRO,C.CCODSBS,C.CNUDOCI,C.CCLAFIN 
from HYO00410.URIESGOS.dbo.[URIRCCMAE808_DIC14] C (NOLOCK)
where C.ccodsbs = '0086863359'

select D.CMESPRO,D.CCODSBS,D.CNUDOCI,D.CCLAFIN 
from HYO00410.URIESGOS.dbo.[URIRCCMAE808_NOV14] D (NOLOCK)
where D.ccodsbs = '0086863359'

select E.CMESPRO,E.CCODSBS,E.CNUDOCI,E.CCLAFIN 
from HYO00410.URIESGOS.dbo.[URIRCCMAE808_OCT14] E (NOLOCK)
where E.ccodsbs = '0086863359'

select F.CMESPRO,F.CCODSBS,F.CNUDOCI,F.CCLAFIN 
from HYO00410.URIESGOS.dbo.[URIRCCMAE808_SET14] F (NOLOCK)
where F.ccodsbs = '0086863359'

-------------------CURSOR-------------------------------------------------
	Declare @ccodsbs1 varchar(10), @feb2015 char(12) , @ene2015 char(12), @dic2014 char(12),
	@nov2014 char(12),@oct2014  char(12), @set2014 char(12)
		Declare cClienteRCC CURSOR FOR					
			select COD_SBS1 from limanorte (NOLOCK) 
					
		OPEN cClienteRCC
		FETCH cClienteRCC into @ccodsbs1
		WHILE (@@FETCH_STATUS=0)
		BEGIN		
	--FEB2015
	set @feb2015 = 
		(select A.CCLAFIN 
		from HYO00410.URIESGOS.dbo.[URIRCCMAE808_FEB15] A (NOLOCK)
		where A.ccodsbs =  @ccodsbs1 ) 										
								Update limanorte
								Set RCC_FEB2015 = @feb2015
								WHERE COD_SBS1 = @ccodsbs1
	--ENE2015
	set @ene2015 = 
			(select B.CCLAFIN 
			from HYO00410.URIESGOS.dbo.[URIRCCMAE808_ENE15] B (NOLOCK)
			where B.ccodsbs = @ccodsbs1 ) 						
					Update limanorte
								Set RCC_ENE2015 = @ene2015
								WHERE COD_SBS1 = @ccodsbs1									
	--DIC2014
	set @dic2014 = 
		(select C.CCLAFIN 
		from HYO00410.URIESGOS.dbo.[URIRCCMAE808_DIC14] C (NOLOCK)
		where C.ccodsbs = @ccodsbs1 ) 			
								Update limanorte
								Set RCC_DIC2014 = @dic2014
								WHERE COD_SBS1 = @ccodsbs1		
	--NOV2014
	set @nov2014 = 
		(select D.CCLAFIN 
		from HYO00410.URIESGOS.dbo.[URIRCCMAE808_NOV14] D (NOLOCK)
		where D.ccodsbs = @ccodsbs1 ) 											
								Update limanorte
								Set RCC_NOV2014 = @nov2014
								WHERE COD_SBS1 = @ccodsbs1							
	--OCT2014
	set @oct2014 = 
		(select E.CCLAFIN 
		from HYO00410.URIESGOS.dbo.[URIRCCMAE808_OCT14] E (NOLOCK)
		where E.ccodsbs = @ccodsbs1 ) 				
								Update limanorte
								Set RCC_OCT2014 = @oct2014
								WHERE COD_SBS1 = @ccodsbs1				
	--SET2014
	set @set2014 = 
		(select F.CCLAFIN 
		from HYO00410.URIESGOS.dbo.[URIRCCMAE808_SET14] F (NOLOCK)
		where F.ccodsbs = @ccodsbs1) 									
								Update limanorte
								Set RCC_SET2014 = @set2014
								WHERE COD_SBS1 = @ccodsbs1					
					
			FETCH cClienteRCC INTO @ccodsbs1
			END
			CLOSE cClienteRCC
			DEALLOCATE cClienteRCC			