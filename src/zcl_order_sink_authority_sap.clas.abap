CLASS zcl_order_sink_authority_sap DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_order_sink_authority.
ENDCLASS.

CLASS zcl_order_sink_authority_sap IMPLEMENTATION.
  METHOD zif_order_sink_authority~check.
    DATA lv_document_type TYPE vbak-auart.
    DATA lv_sales_organization TYPE vbak-vkorg.
    DATA lv_distribution_channel TYPE vbak-vtweg.
    DATA lv_division TYPE vbak-spart.

    SELECT SINGLE auart, vkorg, vtweg, spart
      FROM vbak
      WHERE vbeln = @iv_sales_document
      INTO ( @lv_document_type,
             @lv_sales_organization,
             @lv_distribution_channel,
             @lv_division ).
    IF sy-subrc <> 0.
      DATA lo_context_error TYPE REF TO zcx_stock_allocation.
      CREATE OBJECT lo_context_error.
      lo_context_error->message = 'Sales-order authorization context is unavailable'.
      RAISE EXCEPTION lo_context_error.
    ENDIF.
    IF lv_document_type IS INITIAL
        OR lv_document_type <> iv_sales_document_type
        OR lv_sales_organization IS INITIAL
        OR lv_distribution_channel IS INITIAL
        OR lv_division IS INITIAL.
      DATA lo_invalid_context_error TYPE REF TO zcx_stock_allocation.
      CREATE OBJECT lo_invalid_context_error.
      lo_invalid_context_error->message = 'Sales-order authorization context is invalid'.
      RAISE EXCEPTION lo_invalid_context_error.
    ENDIF.

    AUTHORITY-CHECK OBJECT 'V_VBAK_AAT'
      ID 'AUART' FIELD lv_document_type
      ID 'ACTVT' FIELD '02'.
    IF sy-subrc <> 0.
      DATA lo_error TYPE REF TO zcx_stock_allocation.
      CREATE OBJECT lo_error.
      lo_error->message = 'Sales-order authorization failed'.
      RAISE EXCEPTION lo_error.
    ENDIF.

    AUTHORITY-CHECK OBJECT 'V_VBAK_VKO'
      ID 'VKORG' FIELD lv_sales_organization
      ID 'VTWEG' FIELD lv_distribution_channel
      ID 'SPART' FIELD lv_division
      ID 'ACTVT' FIELD '02'.
    IF sy-subrc <> 0.
      DATA lo_sales_area_error TYPE REF TO zcx_stock_allocation.
      CREATE OBJECT lo_sales_area_error.
      lo_sales_area_error->message = 'Sales-area change authorization failed'.
      RAISE EXCEPTION lo_sales_area_error.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
