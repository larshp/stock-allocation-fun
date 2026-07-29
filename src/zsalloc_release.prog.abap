REPORT zsalloc_release.

PARAMETERS p_matnr TYPE zif_salloc_types=>ty_material OBLIGATORY.
PARAMETERS p_werks TYPE zif_salloc_types=>ty_plant OBLIGATORY.
PARAMETERS p_order TYPE zif_salloc_types=>ty_order_id OBLIGATORY.
PARAMETERS p_qty TYPE zif_salloc_types=>ty_quantity OBLIGATORY.
PARAMETERS p_sim TYPE abap_bool AS CHECKBOX DEFAULT abap_true.

START-OF-SELECTION.
  TRY.
      IF p_qty <= 0.
        RAISE EXCEPTION TYPE zcx_salloc_invalid
          EXPORTING iv_reason = `Release quantity must be positive`.
      ENDIF.

      IF p_sim = abap_true.
        DATA(authorization) = NEW zcl_salloc_authorization_sap( ).
        authorization->zif_salloc_authorization~check_authorization(
          iv_plant = p_werks
          iv_activity = '03' ).
        SELECT SINGLE allocated
          FROM zsalloc_order
          WHERE order_id = @p_order
            AND matnr = @p_matnr
            AND werks = @p_werks
          INTO @DATA(allocated).
        IF sy-subrc <> 0 OR allocated < p_qty.
          RAISE EXCEPTION TYPE zcx_salloc_invalid
            EXPORTING iv_reason = `Release exceeds order allocation`.
        ENDIF.
        WRITE: / 'Simulation: quantity that would be released:', p_qty.
      ELSE.
        DATA(service) = zcl_salloc_factory=>create_sap_service( ).
        service->release(
          iv_material = p_matnr
          iv_plant = p_werks
          iv_order_id = p_order
          iv_quantity = p_qty ).
        WRITE: / 'Released quantity:', p_qty.
      ENDIF.
    CATCH zcx_salloc_invalid INTO DATA(invalid).
      WRITE: / 'Invalid request:', invalid->reason.
      MESSAGE 'Stock allocation release request is invalid' TYPE 'E'.
    CATCH zcx_salloc_integration INTO DATA(integration).
      WRITE: / 'Release failed:', integration->operation, integration->reason.
      MESSAGE 'Stock allocation release failed' TYPE 'E'.
    CATCH cx_sy_open_sql_db INTO DATA(db_error).
      WRITE: / 'Release lookup failed:', db_error->get_text( ).
      MESSAGE 'Stock allocation release lookup failed' TYPE 'E'.
  ENDTRY.
