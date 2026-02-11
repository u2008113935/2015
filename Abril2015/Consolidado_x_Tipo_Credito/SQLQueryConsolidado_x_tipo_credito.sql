--use SOFCMACHYO_DIARIO_NOCHE
--use SOFCMACHYO_DIARIO_mediodia
--use SOFCMACHYO_DIARIO_MANIANA
--Drop Table #salpro
Select * into #salpro FROM  (
Select 
		--top 100
		--CRE.cEstCreCon, (CRE.nMonCapDes - CRE.nMonCapPag) as 'SaldoTotal', CRE.nMonCapDes , CRE.nMonCapPag
		--,CRE.cCodTipCre --, STC.cCodTipCre ,  
		--,CRE.cCodProduc --, STC.cCodProduc , 
		--,CRE.cCodSubPro --, STC.cCodSubPro , 
		--,STC.lEstado , STC.cDessubCre
		STC.cDesTipCre
		,sum((CRE.nMonCapDes - CRE.nMonCapPag)) as 'SaldoTotal'
--select top 5 *
from [KPYMCRECONVEN] CRE (NOLOCK)	
	INNER JOIN [KPYTSUBTIPCRE] STC
			ON CRE.cCodTipCre = STC.cCodTipCre --AND CRE.cCodProduc = STC.cCodProduc 
	--		AND CRE.cCodSubPro = STC.cCodSubPro and STC.lEstado = '1'	
where   --STC.cCodTipCre = ('04') --cDesTipCre : CONSUMO  
		CRE.cEstCreCon = 'F'
		AND CRE.cCodTipCre in  ('02','03','04','09','12','13')
		--and CRE.nDiaAtrCre = '0'
		and STC.lEstado = '1'
		
		/* --en caso de Leasing---
		AND ( (CRE.cCodTipCre = '02' and CRE.cCodSubPro = '13')
		or (CRE.cCodTipCre = '11' and CRE.cCodSubPro = '07')
		or (CRE.cCodTipCre = '12' and CRE.cCodSubPro = '11')
		or (CRE.cCodTipCre = '13' and CRE.cCodSubPro = '13') )		
		*/
			--and (CRE.nMonCapDes - CRE.nMonCapPag) > 0
Group by STC.cDesTipCre 
	)  as tpm01

Select sum(SaldoTotal)
From #salpro

 --/*
 select * from [KPYTSUBTIPCRE] STC
 where STC.cCodTipCre in ('03')
		and STC.lEstado = '1'

		-------------**********lista de productos-------------
			select STC.cCodTipCre, STC.cDesTipCre
				,STC.lEstado
		from [KPYTSUBTIPCRE] STC
		where STC.lEstado = '1'
		--order by STC.cCodTipCre 
		group by  STC.cCodTipCre, STC.cDesTipCre, STC.lEstado
		-----------------*********************************------

select top 10 * from [KPYTSUBTIPCRE] STC 

select STC.cCodTipCre, STC.cCodProduc, STC.cCodSubPro
			--, STC.cDesSubPro, 
			,STC.cDesTipCre, STC.cDesSubTip, STC.cDesProCre, STC.cDesSubCre, STC.lEstado
from [KPYTSUBTIPCRE] STC 
where STC.lEstado = '1'
		and STC.cCodTipCre in ('02','11','12','13')
		and STC.cCodSubPro in ('07','11','13')

Select cDesTipCre,cCodTipCre from [KPYTSUBTIPCRE] STC 	
	where STC.lEstado = '1'
group by cDesTipCre,cCodTipCre

select top 10 * from [KPYDPRODUCTO] PROD

select * from [KPYDPRODUCTO] PROD 
WHERE PROD.lConEstado = '1'
order by PROD.cCodTipCre, PROD.cCodProduc
GROUP BY PROD.cCodTipCre ,PROD.cCodProduc

select 
		PROD.cCodTipCre,
		PROD.cCodProduc
		, PROD.cDesProduct 
from [KPYDPRODUCTO] PROD 
WHERE PROD.lConEstado = '1'
--order by PROD.cCodProduc
GROUP BY PROD.cCodTipCre,PROD.cCodProduc, PROD.cDesProduct


cCodTipCre	cCodProduc	cDesProduct		cDesCorta	lConEstado
02			02			A CUOTA FIJA	          	1

select top 10 * from [KPYDSUBPRODUC] SPRO

select * from [KPYDSUBPRODUC] SPRO 
where cDesSubPro like '%lea%'

cCodTipCre	cCodProduc	cCodSubPro	cDesSubPro	cDesCorta	lConEstado	cDesSubCli	lVerDesSub
02			02			13			LEASING	          		1						0
13			02			13			LEASING	          		1						0
12			02			11			LEASING	          		1						0
11			02			07			LEASING	          		1						0

select * from [KPYTSUBTIPCRE] STC
where (STC.cCodTipCre = '02' and STC.cCodSubPro = '13')
		or (STC.cCodTipCre = '11' and STC.cCodSubPro = '07')
		or (STC.cCodTipCre = '12' and STC.cCodSubPro = '11')
		or (STC.cCodTipCre = '13' and STC.cCodSubPro = '13')
		and STC.lEstado = '1'
	
		---***********Lista detallada de Tipo y SubTipo de Credito,  Producto y SubProducto de Crédito------***			
		Select STC.cCodTipCre, STC.cDesTipCre , STC.cCodSubTip , STC.cDesSubTip
					,STC.cCodProduc, STC.cDesProCre , STC.cCodSubPro,  STC.cDesSubCre, STC.lEstado
			From [KPYTSUBTIPCRE] STC
			Where STC.lEstado = '1'					
					and cCodTipCre in ('02','03','04','10','11','12','13')
			order by cCodTipCre,cCodProduc, cCodSubPro
	
select top 20 *
from [KPYTSUBTIPCRE] STC

select top 20 *
from [KPYDPRODUCTO] PROD

select  *
from [KPYDPRODUCTO] PROD

		---ORDENANDO LA TABLA PRODUCTO---
		select cCodTipCre,cCodProduc,cDesProduct,lConEstado from [KPYDPRODUCTO] PROD 
		order by cCodTipCre

		Select  top 20 *
		from [KPYDSUBPRODUC] SPRO

		Select  *
		from [KPYDSUBPRODUC] SPRO
		where cCodTipCre = '02'


		----------**************LISTA DE SUBPRODUCTOS------------
		Select  *
		from [KPYDSUBPRODUC] SPRO
		where cCodTipCre in ('02','03','04','10','11','12','13')
		order by cCodTipCre,cCodProduc, cCodSubPro
		---------------******************---------------------------

		Select  cCodSubPro
		from [KPYDSUBPRODUC] SPRO
		--where cCodTipCre = '02'
		group by cCodSubPro

		INNER JOIN [HYO00409\HISTORICO].SOFCMACHYO_201502.dbo.[KPYDPRODUCTO] PROD
			ON CRE.cCodProduc =  PROD.cCodProduc and CRE.cCodTipCre = PROD.cCodTipCre
	INNER JOIN [HYO00409\HISTORICO].SOFCMACHYO_201503.dbo.[KPYDSUBPRODUC] SPRO
			ON CRE.cCodSubPro = SPRO.cCodSubPro AND CRE.cCodTipCre = SPRO.cCodTipCre
			AND CRE.cCodProduc =  SPRO.cCodProduc
	INNER JOIN [HYO00409\HISTORICO].SOFCMACHYO_201503.dbo.[KPYTSUBTIPCRE] STC
			ON CRE.cCodTipCre = STC.cCodTipCre AND CRE.cCodProduc = STC.cCodProduc 
			AND CRE.cCodSubPro = STC.cCodSubPro and STC.lEstado = '1'
	--	*/