"! SAP standard stub: MARD - Storage location stock data
"! This is a simulation of the SAP standard table MARD for use with
"! abaplint + transpiler testing only. In a real SAP system the standard
"! table is used directly and this stub must NOT be transported.
CLASS zcl_stub_mard DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_mard_key,
             matnr TYPE matnr,
             werks TYPE werks_d,
             lgort TYPE lgort_d,
           END OF ty_mard_key.
    TYPES tt_mard TYPE STANDARD TABLE OF mard WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_reservation,
             matnr        TYPE matnr,
             werks        TYPE werks_d,
             lgort        TYPE lgort_d,
             qty_reserved TYPE labst,
           END OF ty_reservation.
    TYPES tt_reservations TYPE STANDARD TABLE OF ty_reservation WITH DEFAULT KEY.

    "! Read a single MARD record (simulates SELECT SINGLE from MARD)
    CLASS-METHODS read_single
      IMPORTING
        iv_matnr       TYPE matnr
        iv_werks       TYPE werks_d
        iv_lgort       TYPE lgort_d
      RETURNING
        VALUE(rs_mard) TYPE mard.

    "! Read all MARD records for one material/plant (simulates SELECT from MARD)
    CLASS-METHODS read_by_material_plant
      IMPORTING
        iv_matnr       TYPE matnr
        iv_werks       TYPE werks_d
      RETURNING
        VALUE(rt_mard) TYPE tt_mard.

    "! Test helper: insert/overwrite a simulated MARD row (in-memory)
    CLASS-METHODS insert_row
      IMPORTING
        is_mard TYPE mard.

    "! Reduce unrestricted stock by iv_qty (simulates goods issue posting)
    CLASS-METHODS reduce_stock
      IMPORTING
        iv_matnr TYPE matnr
        iv_werks TYPE werks_d
        iv_lgort TYPE lgort_d
        iv_qty   TYPE labst.

    "! Reserve stock for later consumption; reserved quantities reduce the
    "! stock visible to allocation until released or consumed
    CLASS-METHODS reserve_stock
      IMPORTING
        iv_matnr     TYPE matnr
        iv_werks     TYPE werks_d
        iv_lgort     TYPE lgort_d
        iv_qty       TYPE labst
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    "! Release a reservation (stock becomes allocatable again)
    CLASS-METHODS release_reservation
      IMPORTING
        iv_matnr TYPE matnr
        iv_werks TYPE werks_d
        iv_lgort TYPE lgort_d
        iv_qty   TYPE labst.

    "! Get allocatable stock = unrestricted stock minus reservations
    CLASS-METHODS get_available
      IMPORTING
        iv_matnr            TYPE matnr
        iv_werks          TYPE werks_d
        iv_lgort          TYPE lgort_d
      RETURNING
        VALUE(rv_available) TYPE labst.

    "! Check whether a requested quantity is fully available at one SLoc
    CLASS-METHODS is_available
      IMPORTING
        iv_matnr            TYPE matnr
        iv_werks            TYPE werks_d
        iv_lgort            TYPE lgort_d
        iv_qty              TYPE labst
      RETURNING
        VALUE(rv_available) TYPE abap_bool.

    "! Test helper: clear all simulated rows
    CLASS-METHODS clear.

  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-DATA gt_mard TYPE tt_mard.
    CLASS-DATA gt_reservations TYPE tt_reservations.

ENDCLASS.



CLASS zcl_stub_mard IMPLEMENTATION.


  METHOD read_single.
    READ TABLE gt_mard INTO rs_mard
      WITH KEY matnr = iv_matnr werks = iv_werks lgort = iv_lgort.
    IF sy-subrc <> 0.
      CLEAR rs_mard.
    ENDIF.
  ENDMETHOD.


  METHOD read_by_material_plant.
    LOOP AT gt_mard INTO DATA(ls_mard)
        WHERE matnr = iv_matnr AND werks = iv_werks.
      APPEND ls_mard TO rt_mard.
    ENDLOOP.
  ENDMETHOD.


  METHOD insert_row.
    " note: MODIFY TABLE ... FROM is not used here because the transpiler
    " runtime does not populate keyFields for standard tables, which makes
    " the FROM-key lookup match the first row unconditionally (see ANOMALIES.md)
    READ TABLE gt_mard ASSIGNING FIELD-SYMBOL(<ls_mard>)
      WITH KEY matnr = is_mard-matnr
               werks = is_mard-werks
               lgort = is_mard-lgort.
    IF sy-subrc = 0.
      <ls_mard> = is_mard.
    ELSE.
      APPEND is_mard TO gt_mard.
    ENDIF.
  ENDMETHOD.


  METHOD reduce_stock.
    READ TABLE gt_mard ASSIGNING FIELD-SYMBOL(<ls_mard>)
      WITH KEY matnr = iv_matnr werks = iv_werks lgort = iv_lgort.
    IF sy-subrc = 0.
      <ls_mard>-labst = <ls_mard>-labst - iv_qty.
      IF <ls_mard>-labst < 0.
        <ls_mard>-labst = 0.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD reserve_stock.
    DATA lv_available TYPE labst.

    lv_available = get_available(
        iv_matnr = iv_matnr
        iv_werks = iv_werks
        iv_lgort = iv_lgort ).
    IF lv_available < iv_qty.
      " not enough unreserved stock left
      rv_ok = abap_false.
      RETURN.
    ENDIF.

    READ TABLE gt_reservations ASSIGNING FIELD-SYMBOL(<ls_res>)
      WITH KEY matnr = iv_matnr werks = iv_werks lgort = iv_lgort.
    IF sy-subrc = 0.
      <ls_res>-qty_reserved = <ls_res>-qty_reserved + iv_qty.
    ELSE.
      APPEND VALUE ty_reservation(
          matnr = iv_matnr werks = iv_werks lgort = iv_lgort
          qty_reserved = iv_qty ) TO gt_reservations.
    ENDIF.
    rv_ok = abap_true.
  ENDMETHOD.


  METHOD release_reservation.
    READ TABLE gt_reservations ASSIGNING FIELD-SYMBOL(<ls_res>)
      WITH KEY matnr = iv_matnr werks = iv_werks lgort = iv_lgort.
    IF sy-subrc = 0.
      <ls_res>-qty_reserved = <ls_res>-qty_reserved - iv_qty.
      IF <ls_res>-qty_reserved < 0.
        <ls_res>-qty_reserved = 0.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD get_available.
    DATA(ls_mard) = read_single(
        iv_matnr = iv_matnr
        iv_werks = iv_werks
        iv_lgort = iv_lgort ).
    rv_available = ls_mard-labst.

    READ TABLE gt_reservations INTO DATA(ls_res)
      WITH KEY matnr = iv_matnr werks = iv_werks lgort = iv_lgort.
    IF sy-subrc = 0.
      rv_available = rv_available - ls_res-qty_reserved.
      IF rv_available < 0.
        rv_available = 0.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD is_available.
    DATA(lv_available) = get_available(
        iv_matnr = iv_matnr
        iv_werks = iv_werks
        iv_lgort = iv_lgort ).
    rv_available = boolc( lv_available >= iv_qty ).
  ENDMETHOD.


  METHOD clear.
    CLEAR gt_mard.
    CLEAR gt_reservations.
  ENDMETHOD.


ENDCLASS.
