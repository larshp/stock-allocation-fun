CLASS zcl_demand_in_package DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_demand_reader.

    "! <p class="shorttext synchronized">Cover one package of a plant's materials</p>
    "!
    "! A plant wide run is one job, and one job is one background process. This
    "! splits the materials into as many packages as there are jobs to run, so
    "! the same report can be scheduled several times over and each copy takes
    "! a share. A count of one, or none, is the whole plant, which is what a
    "! site that never split its run keeps.
    "!
    "! @parameter io_demand   | <p class="shorttext synchronized">Reader that says which materials are waiting</p>
    "! @parameter iv_package  | <p class="shorttext synchronized">Package this run covers, 1 to IV_PACKAGES</p>
    "! @parameter iv_packages | <p class="shorttext synchronized">How many packages there are, 0 for one run</p>
    METHODS constructor
      IMPORTING
        io_demand   TYPE REF TO zif_demand_reader
        iv_package  TYPE i DEFAULT 0
        iv_packages TYPE i DEFAULT 0.

    "! <p class="shorttext synchronized">Which package a material belongs to</p>
    "!
    "! A property of the material and the number of packages, and of nothing
    "! else. Two jobs reading the plant a minute apart therefore agree about
    "! every material they both see, even though what they see differs: no
    "! material is covered twice and none is missed because an order arrived
    "! between the two reads.
    "!
    "! @parameter iv_matnr    | <p class="shorttext synchronized">Material number</p>
    "! @parameter iv_packages | <p class="shorttext synchronized">How many packages there are</p>
    "! @parameter rv_package  | <p class="shorttext synchronized">Package number, 1 to IV_PACKAGES</p>
    CLASS-METHODS package_of
      IMPORTING
        iv_matnr          TYPE mard-matnr
        iv_packages       TYPE i
      RETURNING
        VALUE(rv_package) TYPE i.

  PRIVATE SECTION.

    "! What a material number can hold, as far as this has to care. A
    "! character that is not in it counts as nothing, which costs a little
    "! evenness and nothing else.
    CONSTANTS c_alphabet TYPE string
      VALUE `0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-_./ `.

    DATA mo_demand   TYPE REF TO zif_demand_reader.
    DATA mv_package  TYPE i.
    DATA mv_packages TYPE i.

ENDCLASS.


CLASS zcl_demand_in_package IMPLEMENTATION.

  METHOD constructor.

    mo_demand   = io_demand.
    mv_package  = iv_package.
    mv_packages = iv_packages.

  ENDMETHOD.

  METHOD zif_demand_reader~materials_with_demand.

    rt_matnr = mo_demand->materials_with_demand( iv_werks ).

    " one package is no split, and a package number nobody set would otherwise
    " match nothing and quietly allocate an empty plant
    IF mv_packages <= 1 OR mv_package <= 0.
      RETURN.
    ENDIF.

    DATA(lt_kept) = VALUE zif_demand_reader=>ty_matnr_tab( ).

    LOOP AT rt_matnr INTO DATA(lv_matnr).
      IF package_of( iv_matnr    = lv_matnr
                     iv_packages = mv_packages ) = mv_package.
        APPEND lv_matnr TO lt_kept.
      ENDIF.
    ENDLOOP.

    rt_matnr = lt_kept.

  ENDMETHOD.

  METHOD zif_demand_reader~read_open_demand.

    " what a material is owed does not depend on which job looks at it, and a
    " caller naming a material outright means that material
    rt_demand = mo_demand->read_open_demand(
      iv_matnr = iv_matnr
      iv_werks = iv_werks ).

  ENDMETHOD.

  METHOD package_of.

    DATA lv_sum    TYPE i.
    DATA lv_offset TYPE i.
    DATA lv_place  TYPE i.
    DATA lv_char   TYPE c LENGTH 1.

    IF iv_packages <= 1.
      rv_package = 1.
      RETURN.
    ENDIF.

    " the characters looked up in an alphabet and added, position by position,
    " then divided. An alphabet rather than a character code, because the
    " answer has to be the same in every system whatever the code page, and
    " weighted by position so that two materials differing only in the order
    " of their digits do not land in the same package. It is not a checksum
    " and does not have to be one: all it has to be is the same answer every
    " time for the same material.
    DO strlen( iv_matnr ) TIMES.

      lv_offset = sy-index - 1.
      lv_char   = iv_matnr+lv_offset(1).

      lv_place = find( val = c_alphabet
                       sub = lv_char ) + 1.
      IF lv_place < 0.
        CLEAR lv_place.
      ENDIF.

      lv_sum = lv_sum + lv_place * sy-index.

    ENDDO.

    rv_package = lv_sum MOD iv_packages + 1.

  ENDMETHOD.

ENDCLASS.
