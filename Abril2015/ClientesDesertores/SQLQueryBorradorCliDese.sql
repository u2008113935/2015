select  CRE.cCodClaCar, CRE.cCodClaUri
from [HYO00409\HISTORICO].SOFCMACHYO_201503.dbo.[KPYMCRECONVEN] CRE (NOLOCK)
group by  CRE.cCodClaCar , CRE.cCodClaUri


	select top 2  *
	from HYO00410.URIESGOS.dbo.[URIRCCMAE808] A (NOLOCK)
       INNER JOIN HYO00410.URIESGOS.dbo.[URIRCCSAL808] B
             ON A.CCODSBS = B.CCODSBS
       INNER JOIN HYO00410.URIESGOS.dbo.[GENCODSBSEMPSISFIN] C
             ON B.CCODEMP = C.ccodempsisfin


	  select * 
	  from [HYO00409\HISTORICO].SOFCMACHYO_201503.dbo.[KPYTSUBTIPCRE] STC
	  where STC.lEstado = '1' and STC.cCodTipCre in ('13','02','03','12') 