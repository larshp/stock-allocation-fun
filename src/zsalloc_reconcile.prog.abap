REPORT zsalloc_reconcile.

PARAMETERS p_matnr TYPE zif_salloc_types=>ty_material OBLIGATORY.
PARAMETERS p_werks TYPE zif_salloc_types=>ty_plant OBLIGATORY.
PARAMETERS p_sim TYPE abap_bool AS CHECKBOX DEFAULT abap_true.

START-OF-SELECTION.
  TRY.
      DATA(reconciler) = zcl_salloc_factory=>create_sap_reconciler( ).
      DATA(quantity) = reconciler->run(
        iv_material = p_matnr
        iv_plant = p_werks
        iv_simulate = p_sim ).
      IF p_sim = abap_true.
        WRITE: / 'Quantity that would be released:', quantity.
      ELSE.
        WRITE: / 'Released quantity:', quantity.
      ENDIF.
    CATCH zcx_salloc_invalid INTO DATA(invalid).
      WRITE: / 'Invalid request:', invalid->reason.
    CATCH zcx_salloc_integration INTO DATA(integration).
      WRITE: / 'Integration failure:', integration->operation, integration->reason.
  ENDTRY.
