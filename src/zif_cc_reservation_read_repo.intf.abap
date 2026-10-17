INTERFACE zif_cc_reservation_read_repo PUBLIC.

  TYPES:
    BEGIN OF ty_reservation,
      cost_center        TYPE rkpf-kostl,
      reservation_number TYPE resb-rsnum,
      reservation_item   TYPE resb-rspos,
      material           TYPE resb-matnr,
      plant              TYPE resb-werks,
      storage_location   TYPE resb-lgort,
      batch              TYPE resb-charg,
      required_date      TYPE resb-bdter,
      unit               TYPE resb-meins,
      required_quantity  TYPE resb-bdmng,
      withdrawn_quantity TYPE resb-enmng,
      open_quantity      TYPE resb-bdmng,
    END OF ty_reservation.
  TYPES ty_reservations TYPE STANDARD TABLE OF ty_reservation
    WITH EMPTY KEY.
  TYPES ty_cost_centers TYPE STANDARD TABLE OF rkpf-kostl
    WITH EMPTY KEY.
  TYPES:
    BEGIN OF ty_item_key,
      reservation_number TYPE resb-rsnum,
      reservation_item   TYPE resb-rspos,
    END OF ty_item_key.
  TYPES ty_item_keys TYPE STANDARD TABLE OF ty_item_key WITH EMPTY KEY.
  TYPES:
    BEGIN OF ty_item_scope,
      cost_center        TYPE rkpf-kostl,
      reservation_number TYPE resb-rsnum,
      reservation_item   TYPE resb-rspos,
    END OF ty_item_scope.
  TYPES ty_item_scopes TYPE STANDARD TABLE OF ty_item_scope WITH EMPTY KEY.

  METHODS get_open_reservations
    IMPORTING
      iv_cost_center         TYPE rkpf-kostl
    RETURNING
      VALUE(rt_reservations) TYPE ty_reservations.

  METHODS get_open_reservations_bulk
    IMPORTING
      it_cost_centers        TYPE ty_cost_centers
    RETURNING
      VALUE(rt_reservations) TYPE ty_reservations.

  METHODS get_reservation_item_scopes
    IMPORTING
      iv_cost_center   TYPE rkpf-kostl
      it_item_keys     TYPE ty_item_keys
    RETURNING
      VALUE(rt_scopes) TYPE ty_item_scopes.

ENDINTERFACE.
