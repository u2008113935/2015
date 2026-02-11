
		/*																											
	
		Select * From SIPMPersonal
		Where cNomPerson like '%castagnetto%Lemos%Fiorella%' --ICASTA

		Select * from SIPMPersonal
		where cNomPerson like '%Casta%Berrospi%Wilmer%Alison%' --WCASTA

		Select * from SIPMPersonal
		where cNomPerson like '%Caysahuana%Amarillo%Vicente%' --VCAYSA

		Select * from SIPMPersonal
		where cNomPerson like '%Chamorro%Victorio%Hubert%Ivan%' --ICHAMO

		Select * from SIPMPersonal
		where cNomPerson like '%Galindo%Retamozo%Yovana%' --YGALIN

		Select * from SIPMPersonal
		where cNomPerson like '%Guzman%Maldonado%Flor%Maria%' --FGUZMA

		Select * from SIPMPersonal
		where cNomPerson like '%Marcos%Orellana%Cynthia%Victoria%' --CMARCO

		Select * from SIPMPersonal
		where cNomPerson like '%Martinez%Samanez%Armando%' --AMARTS

		Select * from SIPMPersonal
		where cNomPerson like '%Ñahui%Crispin%Danny%David%' --DNAHUI

		Select * from SIPMPersonal
		where cNomPerson like '%Ñique%Apolinario%Jean%Carlos%' --CNIQUE

		Select * from SIPMPersonal
		where cNomPerson like '%Pacheco%Due%Carolyn%Pierina%' --PPACHE

		Select * from SIPMPersonal
		where cNomPerson like '%Pinedo%Davila%Kristian%Valentin%' --KPINED

		Select * from SIPMPersonal
		where cNomPerson like '%Poma%Yapias%Nilton%Daygoro%' --NPOMAY

		Select * from SIPMPersonal
		where cNomPerson like '%Ramirez%Perez%Criss%Wendy%' --SRAMIR

		Select * from SIPMPersonal
		where cNomPerson like '%Ramos%Galv%Jhon%Alexander%' --HRAMOS

		Select * from SIPMPersonal
		where cNomPerson like '%Sipiran%Suarez%Maruxa%Geraldine%' --MSIPIR

		
		Select top 1 * from KPYMCRECONVEN
		*/
		
		SET LANGUAGE spanish;
		/*
		Select 
			ROW_NUMBER() 
			OVER(PARTITION BY year(CRE.DFECDESCRE)
					ORDER BY MONTH (CRE.DFECDESCRE) ) AS Secuencia 
			,Anio= year(CRE.DFECDESCRE), Mes = MONTH (CRE.DFECDESCRE)
			,NombreMes =DATENAME(month, CRE.DFECDESCRE)
			,CRE.cCodCtaCre			
			,CRE.nMonCapDes as 'MontoDesembolso' 
			,(CRE.nMonCapDes - CRE.nMonCapPag) AS 'SaldoCapital'
			,case cre.cCodTipMon
			when '1' then 'SOLES'
			when '2' then 'DOLARES'
			end AS 'Moneda'						
			,left(cast(CRE.dFecDesCre as date),10) as 'FechaDesembolsoCredito'							
			,CRE.cEstCreCon			
			,EstadoCredito =
			 Case CRE.cEstCreCon
			 when 'G' then 'CANCELADO' 
			 ELSE D.cDesConCre
			 END	
			,CRE.cCodUsuAna AS 'CodAsesorActual'
			,SP.cNomPerson AS 'NombreAsesorActual'
			,Oficina = O.cDesOficin										
			,Zona = ZON.cDesZona				
		FROM [KPYMCRECONVEN] CRE (NOLOCK)	
			INNER JOIN [GENMCRECLI] CLI 
				ON CLI.cCodCtaCre = CRE.cCodCtaCre				
			INNER JOIN [GENTOficinas] O 
				ON O.cCodOficin = CRE.cCodOficin and O.lConEstado = '1'			
			INNER JOIN [Gentofizonas] GOZ
				ON GOZ.cCodOficin = O.cCodOficin and GOZ.lEstZonOfi = '1'
			INNER JOIN [GentZonas] ZON
				ON ZON.nCodZona = GOZ.nCodZona	
			inner JOIN [sipmpersonal] SP 
				ON SP.cCodPerson = CRE.cCodUsuAna	
			INNER JOIN [KPYTConCredit] D
				ON D.cCondicCon = CLI.cCondicCon
		Where CRE.cCodUsuAna 
			in ('ICASTA','WCASTA','VCAYSA','ICHAMO','YGALIN','FGUZMA','CMARCO','AMARTS'
			,'DNAHUI','CNIQUE','PPACHE','KPINED','NPOMAY','SRAMIR','HRAMOS','MSIPIR')
			and CRE.cEstCreCon in ('F','H','I')
		Order by CRE.cCodUsuAna 
		*/
		
		Select 		
			CRE.cCodUsuAna AS 'CodAsesorActual'
			,SP.cNomPerson AS 'NombreAsesorActual'
			,CantCreditos = count(CRE.cCodCtaCre)
			,CRE.cEstCreCon
			,EC.cDescriEst AS 'EstadoCredito'																			
			,EstadoCredito =
			 Case CRE.cEstCreCon
			 when 'G' then 'CANCELADO' 
			 ELSE D.cDesConCre
			 END			
			,Oficina = O.cDesOficin										
			,Zona = ZON.cDesZona				
		FROM [KPYMCRECONVEN] CRE (NOLOCK)	
			INNER JOIN [GENMCRECLI] CLI 
				ON CLI.cCodCtaCre = CRE.cCodCtaCre				
			INNER JOIN [GENTOficinas] O 
				ON O.cCodOficin = CRE.cCodOficin and O.lConEstado = '1'			
			INNER JOIN [Gentofizonas] GOZ
				ON GOZ.cCodOficin = O.cCodOficin and GOZ.lEstZonOfi = '1'
			INNER JOIN [GentZonas] ZON
				ON ZON.nCodZona = GOZ.nCodZona	
			inner JOIN [sipmpersonal] SP 
				ON SP.cCodPerson = CRE.cCodUsuAna	
			INNER JOIN [KPYTConCredit] D
				ON D.cCondicCon = CLI.cCondicCon
			INNER JOIN KPYTEstCreCon EC 
				ON EC.cEstCreCon = CRE.cEstCreCon

		Where CRE.cCodUsuAna 
			in ('ICASTA','WCASTA','VCAYSA','ICHAMO','YGALIN','FGUZMA','CMARCO','AMARTS'
			,'DNAHUI','CNIQUE','PPACHE','KPINED','NPOMAY','SRAMIR','HRAMOS','MSIPIR')
			and CRE.cEstCreCon != 'G' --in ('F','H','I')
		Group By CRE.cCodUsuAna, SP.cNomPerson,CRE.cEstCreCon,EC.cDescriEst
			,CRE.cEstCreCon, D.cDesConCre,O.cDesOficin, ZON.cDesZona	
		Order by CRE.cCodUsuAna

		/*
		Select cCodPerson,cNomPerson,dFecCesIns
		from SIPMPersonal
		where cCodPerson 
			in ('ICASTA','WCASTA','VCAYSA','ICHAMO','YGALIN','FGUZMA','CMARCO','AMARTS'
			,'DNAHUI','CNIQUE','PPACHE','KPINED','NPOMAY','SRAMIR','HRAMOS','MSIPIR')
		*/