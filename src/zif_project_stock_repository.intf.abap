INTERFACE zif_project_stock_repository PUBLIC.

  TYPES ty_wbs_element TYPE c LENGTH 24.
  TYPES ty_wbs_elements TYPE STANDARD TABLE OF ty_wbs_element
    WITH EMPTY KEY.
  TYPES:
    BEGIN OF ty_key,
      material    TYPE mard-matnr,
      plant       TYPE mard-werks,
      wbs_element TYPE ty_wbs_element,
    END OF ty_key.
  TYPES ty_keys TYPE STANDARD TABLE OF ty_key WITH EMPTY KEY.
  TYPES:
    BEGIN OF ty_stock,
      material              TYPE mard-matnr,
      plant                 TYPE mard-werks,
      wbs_element           TYPE ty_wbs_element,
      storage_location      TYPE mard-lgort,
      batch                 TYPE mchb-charg,
      expiration_date       TYPE mcha-vfdat,
      unrestricted_quantity TYPE mspr-prlab,
    END OF ty_stock.
  TYPES ty_stocks TYPE STANDARD TABLE OF ty_stock WITH EMPTY KEY.
  TYPES:
    BEGIN OF ty_reservation,
      reservation_number TYPE resb-rsnum,
      reservation_item   TYPE resb-rspos,
      material           TYPE mard-matnr,
      plant              TYPE mard-werks,
      wbs_element        TYPE ty_wbs_element,
      storage_location   TYPE mard-lgort,
      batch              TYPE mchb-charg,
      required_date      TYPE resb-bdter,
      unit               TYPE resb-meins,
      entry_unit         TYPE resb-erfme,
      required_quantity  TYPE resb-bdmng,
      withdrawn_quantity TYPE resb-enmng,
      open_quantity      TYPE resb-bdmng,
      is_final_issue     TYPE resb-kzear,
    END OF ty_reservation.
  TYPES ty_reservations TYPE STANDARD TABLE OF
    ty_reservation WITH EMPTY KEY.

  METHODS read_project_stocks
    IMPORTING
      it_keys          TYPE ty_keys
    RETURNING
      VALUE(rt_stocks) TYPE ty_stocks.

  METHODS read_project_stocks_wbs
    IMPORTING
      it_wbs_elements  TYPE ty_wbs_elements
    RETURNING
      VALUE(rt_stocks) TYPE ty_stocks.

  METHODS read_project_reservations
    IMPORTING
      it_keys                TYPE ty_keys
    RETURNING
      VALUE(rt_reservations) TYPE ty_reservations.

  METHODS read_project_reservations_wbs
    IMPORTING
      it_wbs_elements        TYPE ty_wbs_elements
    RETURNING
      VALUE(rt_reservations) TYPE ty_reservations.

  METHODS read_project_resv_items_wbs
    IMPORTING
      it_wbs_elements        TYPE ty_wbs_elements
    RETURNING
      VALUE(rt_reservations) TYPE ty_reservations.

ENDINTERFACE.
