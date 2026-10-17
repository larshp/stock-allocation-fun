INTERFACE zif_prod_order_atp_checker PUBLIC.

  TYPES:
    BEGIN OF ty_order_readiness,
      production_order          TYPE zif_prod_order_api=>ty_order_number,
      component_count           TYPE i,
      not_fully_confirmed_count TYPE i,
      requested_base_quantity   TYPE mard-labst,
      confirmed_base_quantity   TYPE mard-labst,
      unconfirmed_base_quantity TYPE mard-labst,
      is_fully_confirmed        TYPE abap_bool,
    END OF ty_order_readiness.
  TYPES ty_order_readinesses TYPE STANDARD TABLE OF ty_order_readiness
    WITH EMPTY KEY.

  METHODS check_components
    IMPORTING
      it_production_orders TYPE zif_prod_order_api=>ty_order_numbers
      iv_check_rule        TYPE zif_material_availability_api=>ty_check_rule
    RETURNING
      VALUE(rt_readiness)  TYPE ty_order_readinesses
    RAISING
      zcx_invalid_production_order
      zcx_invalid_stock_request.

ENDINTERFACE.
