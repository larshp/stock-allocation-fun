CLASS zcl_prod_order_atp_checker DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_prod_order_atp_checker.

    METHODS constructor
      IMPORTING
        io_component_service TYPE REF TO zcl_prod_comp_service.

    CLASS-METHODS map_summaries
      IMPORTING
        it_production_orders TYPE zif_prod_order_api=>ty_order_numbers
        it_summaries         TYPE zcl_prod_comp_service=>ty_component_order_atp_summaries
      RETURNING
        VALUE(rt_readiness)  TYPE zif_prod_order_atp_checker=>ty_order_readinesses
      RAISING
        zcx_invalid_stock_request.

  PRIVATE SECTION.
    DATA mo_component_service TYPE REF TO zcl_prod_comp_service.
ENDCLASS.

CLASS zcl_prod_order_atp_checker IMPLEMENTATION.

  METHOD constructor.
    mo_component_service = io_component_service.
  ENDMETHOD.

  METHOD zif_prod_order_atp_checker~check_components.
    DATA(lt_checks) = mo_component_service->preview_components_atp_bulk(
      it_production_orders = it_production_orders
      iv_check_rule        = iv_check_rule ).
    DATA(lt_summaries) = mo_component_service->summarize_order_atp(
      it_checks = lt_checks ).

    rt_readiness = map_summaries(
      it_production_orders = it_production_orders
      it_summaries         = lt_summaries ).
  ENDMETHOD.

  METHOD map_summaries.
    DATA lv_requested_total TYPE decfloat34.
    DATA lv_confirmed_total TYPE decfloat34.
    DATA lv_unconfirmed_total TYPE decfloat34.

    LOOP AT it_production_orders INTO DATA(lv_production_order).
      CLEAR: lv_requested_total, lv_confirmed_total,
        lv_unconfirmed_total.
      DATA(ls_readiness) = VALUE zif_prod_order_atp_checker=>ty_order_readiness(
        production_order   = lv_production_order
        is_fully_confirmed = abap_true ).

      LOOP AT it_summaries INTO DATA(ls_summary)
          WHERE production_order = lv_production_order.
        ADD ls_summary-component_count TO ls_readiness-component_count.
        lv_requested_total += CONV decfloat34(
          ls_summary-requested_base_quantity ).
        lv_confirmed_total += CONV decfloat34(
          ls_summary-confirmed_base_quantity ).
        lv_unconfirmed_total += CONV decfloat34(
          ls_summary-unconfirmed_base_quantity ).
        ADD ls_summary-unconfirmed_count
          TO ls_readiness-not_fully_confirmed_count.
        ADD ls_summary-partially_confirmed_count
          TO ls_readiness-not_fully_confirmed_count.

        IF ls_summary-is_split_fully_confirmed <> abap_true
            OR ls_summary-unconfirmed_count > 0
            OR ls_summary-partially_confirmed_count > 0
            OR ls_summary-unconfirmed_base_quantity > 0.
          ls_readiness-is_fully_confirmed = abap_false.
        ENDIF.
      ENDLOOP.

      TRY.
          ls_readiness-requested_base_quantity = CONV mard-labst(
            lv_requested_total ).
          ls_readiness-confirmed_base_quantity = CONV mard-labst(
            lv_confirmed_total ).
          ls_readiness-unconfirmed_base_quantity = CONV mard-labst(
            lv_unconfirmed_total ).
        CATCH cx_sy_conversion_overflow.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDTRY.
      APPEND ls_readiness TO rt_readiness.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
