CLASS zcl_bapi_mat_avail_api DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_material_availability_api.
    TYPES ty_bapi_confirmations TYPE STANDARD TABLE OF bapiwmdve
      WITH EMPTY KEY.
    CLASS-METHODS map_confirmation_lines
      IMPORTING
        it_bapi_confirmations        TYPE ty_bapi_confirmations
      RETURNING
        VALUE(rt_confirmation_lines) TYPE
          zif_material_availability_api=>ty_confirmation_lines.
ENDCLASS.

CLASS zcl_bapi_mat_avail_api IMPLEMENTATION.

  METHOD zif_material_availability_api~check_availability.
    DATA ls_requirement TYPE bapiwmdvs.
    DATA lt_requirements TYPE STANDARD TABLE OF bapiwmdvs
      WITH DEFAULT KEY.
    DATA ls_confirmation TYPE bapiwmdve.
    DATA lt_confirmations TYPE ty_bapi_confirmations.
    DATA lv_available_at_plant TYPE mard-labst.
    DATA lv_endleadtme TYPE bapicm61m-wzter.
    DATA lv_dialog_flag TYPE c LENGTH 1.

    ls_requirement-req_date = is_request-required_date.
    ls_requirement-req_qty = is_request-requested_quantity.
    APPEND ls_requirement TO lt_requirements.

    CALL FUNCTION 'BAPI_MATERIAL_AVAILABILITY'
      EXPORTING
        material   = is_request-material
        plant      = is_request-plant
        unit       = is_request-unit
        check_rule = is_request-check_rule
      IMPORTING
        av_qty_plt = lv_available_at_plant
        endleadtme = lv_endleadtme
        dialogflag = lv_dialog_flag
      TABLES
        wmdvsx     = lt_requirements
        wmdvex     = lt_confirmations.

    rs_result-material = is_request-material.
    rs_result-plant = is_request-plant.
    rs_result-unit = is_request-unit.
    rs_result-check_rule = is_request-check_rule.
    rs_result-required_date = is_request-required_date.
    rs_result-requested_quantity = is_request-requested_quantity.
    rs_result-available_at_plant_quantity = lv_available_at_plant.
    rs_result-end_of_replenishment_lead_time = lv_endleadtme.
    rs_result-confirmation_lines = map_confirmation_lines(
      it_bapi_confirmations = lt_confirmations ).
    rs_result-dialog_flag = lv_dialog_flag.
    rs_result-is_fully_available = xsdbool( lv_dialog_flag = space ).
    rs_result-is_check_relevant = xsdbool( lv_dialog_flag <> 'N' ).

    READ TABLE lt_confirmations INDEX 1 INTO ls_confirmation.
    IF sy-subrc = 0.
      rs_result-confirmed_date = ls_confirmation-com_date.
      rs_result-confirmed_quantity = ls_confirmation-com_qty.
    ENDIF.
  ENDMETHOD.

  METHOD map_confirmation_lines.
    LOOP AT it_bapi_confirmations INTO DATA(ls_confirmation).
      APPEND VALUE #(
        requested_date     = ls_confirmation-req_date
        requested_quantity = ls_confirmation-req_qty
        confirmed_date     = ls_confirmation-com_date
        confirmed_quantity = ls_confirmation-com_qty )
        TO rt_confirmation_lines.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
