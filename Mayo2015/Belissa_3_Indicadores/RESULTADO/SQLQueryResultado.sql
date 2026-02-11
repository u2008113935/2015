select * from EvoCartCol WHERE CodOfi = '002'
select * from MetCred WHERE CodOfi = '002'
--drop table MetCred
Select 
  M.DescZona, M.CodOfi, M.DesOfi
  ,M.CartTotEne2015 as 'MetaMemoEne2015',E.C201501 AS 'CierreEne2015'	
  ,M.CartTotFeb2015 as 'MetaMemoFeb2015',E.C201502 AS 'CierreFeb2015'	
  ,M.CartTotMar2015 AS 'MetaMemoMarb2015',E.C201503 AS 'CierreMar2015'
  , Case M.CartTotEne2015 when 0 then 0
	else ((E.C201501/M.CartTotEne2015)*100) end AS 'PorcAvanEne2015'
  , Case M.CartTotFeb2015 when 0 then 0
	else ((E.C201502/M.CartTotFeb2015)*100) end AS 'PorcAvanFeb2015'
  , Case M.CartTotMar2015 when 0 then 0
	else ((E.C201503/M.CartTotMar2015)*100) end AS 'PorcAvanMar2015'	 
from [EvoCartCol] E
		INNER JOIN [MetCred] M
			ON M.CodOfi = E.CodOfi
WHERE M.CodZona in ('1','2','3','4','5')
ORDER BY M.CodZona, M.CodOfi

/*
Select 
  M.DescZona, M.CodOfi, M.DesOfi
  ,(M.CartTotEne2015 - E.C201412) AS 'MetaMemoEne2015',(E.C201501 - E.C201412) AS 'CierreEne2015'	
  ,(M.CartTotFeb2015 - E.C201501) AS 'MetaMemoFeb2015',(E.C201502 - E.C201501)	AS 'CierreFeb2015'	
  ,(M.CartTotMar2015 - E.C201502) AS 'MetaMemoMarb2015',(E.C201503 - E.C201502) AS 'CierreMar2015'
	 --AS 'PORCENTAJE_AVANCE_ENERO'
	 --AS 'PORCENTAJE_AVANCE_FEBRERO'
	 --AS 'PORCENTAJE_AVANCE_MARZO'	 
from [EvoCartCol] E
		INNER JOIN [MetCred] M
			ON M.CodOfi = E.CodOfi
WHERE M.CodZona in ('1','2','3','4','5')
ORDER BY M.CodZona, M.CodOfi
*/

