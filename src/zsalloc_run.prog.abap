REPORT zsalloc_run.

PARAMETERS p_matnr TYPE zif_salloc_types=>ty_material OBLIGATORY.
PARAMETERS p_werks TYPE zif_salloc_types=>ty_plant OBLIGATORY.
PARAMETERS p_sim TYPE abap_bool AS CHECKBOX DEFAULT abap_true.

START-OF-SELECTION.
  TRY.
      DATA(service) = zcl_salloc_factory=>create_sap_service( ).
      DATA(allocations) = service->run(
        iv_material = p_matnr
        iv_plant = p_werks
        iv_simulate = p_sim ).

      WRITE: / 'Order/schedule line', 24 'Requested', 40 'Allocated', 56 'Shortage'.
      LOOP AT allocations ASSIGNING FIELD-SYMBOL(<allocation>).
        WRITE: / <allocation>-order_id,
                 24 <allocation>-requested,
                 40 <allocation>-allocated,
                 56 <allocation>-shortage.
      ENDLOOP.
    CATCH zcx_salloc_invalid INTO DATA(invalid).
      WRITE: / 'Invalid request:', invalid->reason.
    CATCH zcx_salloc_integration INTO DATA(integration).
      WRITE: / 'Integration failure:', integration->operation, integration->reason.
  ENDTRY.
