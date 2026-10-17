INTERFACE zif_prod_order_read_repo PUBLIC.

  TYPES ty_order_number TYPE aufk-aufnr.
  TYPES ty_order_numbers TYPE STANDARD TABLE OF ty_order_number
    WITH EMPTY KEY.
  TYPES:
    BEGIN OF ty_order_item,
      production_order          TYPE afpo-aufnr,
      production_item           TYPE afpo-posnr,
      order_category            TYPE aufk-autyp,
      material                  TYPE afpo-matnr,
      plant                     TYPE afpo-werks,
      order_unit                TYPE afpo-amein,
      base_unit                 TYPE afpo-meins,
      basic_start_date          TYPE afko-gstrp,
      basic_finish_date         TYPE afko-gltrp,
      order_quantity            TYPE afpo-psmng,
      received_quantity         TYPE afpo-wemng,
      order_to_base_numerator   TYPE afpo-umrez,
      order_to_base_denominator TYPE afpo-umren,
      phase_1_indicator         TYPE aufk-phas1,
      phase_2_indicator         TYPE aufk-phas2,
      phase_3_indicator         TYPE aufk-phas3,
      order_deletion_indicator  TYPE aufk-loekz,
      receipt_expected          TYPE afpo-wepos,
      item_deletion_indicator   TYPE afpo-xloek,
      delivery_complete         TYPE afpo-elikz,
    END OF ty_order_item.
  TYPES ty_order_items TYPE STANDARD TABLE OF ty_order_item WITH EMPTY KEY.
  TYPES:
    BEGIN OF ty_order_status,
      production_order  TYPE ty_order_number,
      status_code       TYPE jest-stat,
      status_profile    TYPE aufk-stsma,
      is_user_status    TYPE abap_bool,
      status_short_name TYPE tj02t-txt04,
      status_name       TYPE tj02t-txt30,
    END OF ty_order_status.
  TYPES ty_order_statuses TYPE STANDARD TABLE OF ty_order_status
    WITH EMPTY KEY.
  TYPES:
    BEGIN OF ty_order_confirmation,
      production_order     TYPE afru-aufnr,
      operation_number     TYPE afvc-vornr,
      operation_sequence   TYPE afvc-plnfl,
      confirmation         TYPE afru-rueck,
      confirmation_counter TYPE afru-rmzhl,
      posting_date         TYPE afru-budat,
      yield_quantity       TYPE afru-lmnga,
      rework_quantity      TYPE afru-rmnga,
      scrap_quantity       TYPE afru-xmnga,
      quantity_unit        TYPE afru-meinh,
      is_final             TYPE afru-aueru,
      is_reversed          TYPE afru-stokz,
    END OF ty_order_confirmation.
  TYPES ty_order_confirmations TYPE STANDARD TABLE OF
    ty_order_confirmation WITH EMPTY KEY.
  TYPES:
    BEGIN OF ty_order_operation,
      production_order      TYPE afko-aufnr,
      operation_counter     TYPE afvc-aplzl,
      operation_sequence    TYPE afvc-plnfl,
      operation_number      TYPE afvc-vornr,
      suboperation_number   TYPE afvc-uvorn,
      operation_description TYPE afvc-ltxa1,
      control_key           TYPE afvc-steus,
    END OF ty_order_operation.
  TYPES ty_order_operations TYPE STANDARD TABLE OF ty_order_operation
    WITH EMPTY KEY.

  METHODS read_orders
    IMPORTING
      it_production_orders  TYPE ty_order_numbers
    RETURNING
      VALUE(rt_order_items) TYPE ty_order_items.

  METHODS read_order_statuses
    IMPORTING
      it_production_orders TYPE ty_order_numbers
    RETURNING
      VALUE(rt_statuses)   TYPE ty_order_statuses.

  METHODS read_confirmations
    IMPORTING
      it_production_orders    TYPE ty_order_numbers
    RETURNING
      VALUE(rt_confirmations) TYPE ty_order_confirmations.

  METHODS read_operations
    IMPORTING
      it_production_orders TYPE ty_order_numbers
    RETURNING
      VALUE(rt_operations) TYPE ty_order_operations.

ENDINTERFACE.
