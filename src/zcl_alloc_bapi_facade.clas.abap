CLASS zcl_alloc_bapi_facade DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_call,
             name     TYPE c LENGTH 20,
             matnr    TYPE matnr,
             werks    TYPE werks_d,
             quantity TYPE menge_d,
           END OF ty_call.

    TYPES: BEGIN OF ty_result,
             success TYPE abap_bool,
             message TYPE c LENGTH 80,
           END OF ty_result.

    METHODS call
      IMPORTING
        is_call          TYPE ty_call
      RETURNING
        VALUE(rs_result) TYPE ty_result.

ENDCLASS.


CLASS zcl_alloc_bapi_facade IMPLEMENTATION.

  METHOD call.
    DATA ls_gm         TYPE zcl_alloc_bapi_gm=>ty_input.
    DATA ls_gm_result  TYPE zcl_alloc_bapi_gm=>ty_result.
    DATA ls_atp        TYPE zcl_alloc_bapi_atp=>ty_input.
    DATA ls_atp_result TYPE zcl_alloc_bapi_atp=>ty_result.
    DATA lo_gm         TYPE REF TO zcl_alloc_bapi_gm.
    DATA lo_atp        TYPE REF TO zcl_alloc_bapi_atp.
    DATA lv_message    TYPE string.

    CASE is_call-name.
      WHEN 'GOODS_MOVEMENT'.
        lo_gm = NEW zcl_alloc_bapi_gm( ).
        ls_gm-matnr = is_call-matnr.
        ls_gm-werks = is_call-werks.
        ls_gm-lgort = '0001'.
        ls_gm-quantity = is_call-quantity.
        ls_gm-move_type = '311'.

        ls_gm_result = lo_gm->post( ls_gm ).

        rs_result-success = ls_gm_result-executed.
        IF ls_gm_result-executed = abap_true.
          rs_result-message = ls_gm_result-doc_number.
        ELSE.
          READ TABLE ls_gm_result-messages INTO lv_message INDEX 1.
          IF sy-subrc = 0.
            rs_result-message = lv_message.
          ENDIF.
        ENDIF.

      WHEN 'AVAILABILITY'.
        lo_atp = NEW zcl_alloc_bapi_atp( ).
        ls_atp-matnr = is_call-matnr.
        ls_atp-werks = is_call-werks.
        ls_atp-quantity = is_call-quantity.
        ls_atp-stock = is_call-quantity.

        ls_atp_result = lo_atp->check( ls_atp ).

        rs_result-success = ls_atp_result-available.
        IF ls_atp_result-available = abap_true.
          rs_result-message = 'Available'.
        ELSE.
          rs_result-message = 'Not available'.
        ENDIF.

      WHEN OTHERS.
        rs_result-success = abap_false.
        rs_result-message = 'Unknown BAPI'.
    ENDCASE.
  ENDMETHOD.

ENDCLASS.
