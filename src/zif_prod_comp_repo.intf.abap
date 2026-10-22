INTERFACE zif_prod_comp_repo PUBLIC.

  TYPES:
    BEGIN OF ty_reservation_item,
      production_order   TYPE resb-aufnr,
      planned_order      TYPE resb-plnum,
      reservation_number TYPE resb-rsnum,
      reservation_item   TYPE resb-rspos,
      material           TYPE resb-matnr,
      plant              TYPE resb-werks,
      storage_location   TYPE resb-lgort,
      batch              TYPE resb-charg,
      movement_type      TYPE resb-bwart,
      required_date      TYPE resb-bdter,
      required_quantity  TYPE resb-bdmng,
      withdrawn_quantity TYPE resb-enmng,
      unit               TYPE resb-meins,
      is_deleted         TYPE resb-xloek,
      is_final_issue     TYPE resb-kzear,
    END OF ty_reservation_item.
  TYPES ty_reservation_items TYPE STANDARD TABLE OF ty_reservation_item
    WITH EMPTY KEY.
  TYPES ty_production_orders TYPE STANDARD TABLE OF resb-aufnr WITH EMPTY KEY.
  TYPES ty_planned_orders TYPE STANDARD TABLE OF resb-plnum WITH EMPTY KEY.
  TYPES:
    BEGIN OF ty_required_date_range,
      filter_from                TYPE abap_bool,
      required_date_from         TYPE resb-bdter,
      filter_through             TYPE abap_bool,
      required_date_through      TYPE resb-bdter,
      filter_bucket              TYPE abap_bool,
      required_date_bucket       TYPE c LENGTH 1,
      required_date_horizon_days TYPE i,
      as_of_date                 TYPE d,
    END OF ty_required_date_range.

  METHODS get_components
    IMPORTING
      iv_production_order    TYPE resb-aufnr
      is_required_date_range TYPE ty_required_date_range OPTIONAL
    RETURNING
      VALUE(rt_items)        TYPE ty_reservation_items.

  METHODS get_components_bulk
    IMPORTING
      it_production_orders   TYPE ty_production_orders
      is_required_date_range TYPE ty_required_date_range OPTIONAL
    RETURNING
      VALUE(rt_items)        TYPE ty_reservation_items.

  METHODS get_planned_comp
    IMPORTING
      iv_planned_order       TYPE resb-plnum
      is_required_date_range TYPE ty_required_date_range OPTIONAL
    RETURNING
      VALUE(rt_items)        TYPE ty_reservation_items.

  METHODS get_planned_comp_bulk
    IMPORTING
      it_planned_orders      TYPE ty_planned_orders
      is_required_date_range TYPE ty_required_date_range OPTIONAL
    RETURNING
      VALUE(rt_items)        TYPE ty_reservation_items.

ENDINTERFACE.
