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

    "! Read a single MARD record (simulates SELECT SINGLE from MARD)
    CLASS-METHODS read_single
      IMPORTING
        iv_matnr       TYPE matnr
        iv_werks        TYPE werks_d
        iv_lgort        TYPE lgort_d
      RETURNING
        VALUE(rs_mard)  TYPE mard.

    "! Read all MARD records for one material/plant (simulates SELECT from MARD)
    CLASS-METHODS read_by_material_plant
      IMPORTING
        iv_matnr         TYPE matnr
        iv_werks         TYPE werks_d
      RETURNING
        VALUE(rt_mard)   TYPE STANDARD TABLE OF mard WITH DEFAULT KEY.

    "! Test helper: insert/overwrite a simulated MARD row (in-memory)
    CLASS-METHODS insert_row
      IMPORTING
        is_mard TYPE mard.

    "! Test helper: clear all simulated rows
    CLASS-METHODS clear.

  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-DATA gt_mard TYPE STANDARD TABLE OF mard WITH DEFAULT KEY.

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
    MODIFY TABLE gt_mard FROM is_mard.
  ENDMETHOD.


  METHOD clear.
    CLEAR gt_mard.
  ENDMETHOD.


ENDCLASS.
