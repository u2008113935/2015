
	/*
		Código del deudor,  nombre del deudor,  número de documento del deudor, tipo de crédito
		, modalidad del crédito, tipo de moneda,  número del crédito,  destino del crédito
		, fuente de ingresos del deudor
		, línea de financiamiento, fecha de desembolso
		,  monto desembolsado, número de cuotas del crédito	, cuota a pagar
			, número de cuotas pagadas
		, saldo capital, estado contable
				, días de atraso al cierre de agosto y setiembre 2015
		, clasificación final, provisión, tipo de garantía, monto del gravamen.

	*/
	
		Select * from Cofide
			-- (2,730 row(s) affected)

		Select * from Cofide02
		Select * from CofideProv

		---- Final

		Select A.* 
			,B.NroDocumento, B.EstadoContable, B.CuotaPag, B.CuotaPend, B.DescripcionTipoGarantia
			,B.MontoGravamenSoles, B.Cuota, B.TipoFuenteIngresos, B.NombreFuenteIngresos
			,MontoProvision = isnull(C.nMontoProvF,0), FechaProvision = isnull(C.cCodFecMes,'')	
		From Cofide A
			left join Cofide02 B
				on A.CodigoCredito = B.CodigoCredito
			left join CofideProv C
				on C.cCodCtaCre = A.CodigoCredito

		------------------------------------------------------------------------------------------

		