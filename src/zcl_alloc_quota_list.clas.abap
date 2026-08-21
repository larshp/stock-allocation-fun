CLASS zcl_alloc_quota_list DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES ty_line_tab TYPE STANDARD TABLE OF string WITH EMPTY KEY.

    "! What is shown where a quota row names no customer and nobody has taken
    "! anything against it yet.
    CONSTANTS c_anybody TYPE c LENGTH 10 VALUE 'anybody'.

    "! <p class="shorttext synchronized">List wired up the way a plain SAP system needs it</p>
    "!
    "! @parameter ro_list | <p class="shorttext synchronized">Ready to use list</p>
    CLASS-METHODS create_default
      RETURNING
        VALUE(ro_list) TYPE REF TO zcl_alloc_quota_list.

    "! <p class="shorttext synchronized">Wire up the list</p>
    "!
    "! @parameter io_store     | <p class="shorttext synchronized">Where runs are recorded</p>
    "! @parameter io_authority | <p class="shorttext synchronized">Decides who may see a plant</p>
    METHODS constructor
      IMPORTING
        io_store     TYPE REF TO zif_allocation_store
        io_authority TYPE REF TO zif_allocation_authority.

    "! <p class="shorttext synchronized">How each quota of a plant stands</p>
    "!
    "! A quota is a promise to a customer, and until something is short it is
    "! invisible: nothing says how much of it the last run handed over, and
    "! nobody finds out that a figure was typed a nought short until a line is
    "! cut back by it. This puts the rows of `ZSTOCK_ALLOC_QTA` next to what
    "! the last run confirmed against each of them.
    "!
    "! What was taken is what the newest recorded run of the material
    "! confirmed for that customer inside the period, because that is what the
    "! quota is a limit on: the run's own answer, not a total of every run
    "! ever recorded. A re-cut replaces its predecessor rather than adding to
    "! it, which is the same reason feature 86 gives.
    "!
    "! @parameter iv_werks       | <p class="shorttext synchronized">Plant</p>
    "! @parameter iv_matnr       | <p class="shorttext synchronized">Material, every one if empty</p>
    "! @parameter rt_line        | <p class="shorttext synchronized">Lines to display</p>
    "! @raising   zcx_allocation | <p class="shorttext synchronized">Plant may not be seen</p>
    METHODS run
      IMPORTING
        iv_werks       TYPE mard-werks
        iv_matnr       TYPE mard-matnr OPTIONAL
      RETURNING
        VALUE(rt_line) TYPE ty_line_tab
      RAISING
        zcx_allocation.

  PRIVATE SECTION.

    CONSTANTS c_width_matnr  TYPE i VALUE 20.
    CONSTANTS c_width_kunnr  TYPE i VALUE 12.
    CONSTANTS c_width_period TYPE i VALUE 26.
    CONSTANTS c_width_qty    TYPE i VALUE 13.

    "! Reading what was agreed and what was given, not changing either.
    CONSTANTS c_activity_display TYPE activ_auth VALUE '03'.

    "! One quota row. Declared explicitly rather than inferred with
    "! INTO TABLE @DATA(), see ANOMALIES.md.
    TYPES:
      BEGIN OF ty_quota,
        matnr     TYPE zstock_alloc_qta-matnr,
        kunnr     TYPE zstock_alloc_qta-kunnr,
        date_from TYPE zstock_alloc_qta-date_from,
        date_to   TYPE zstock_alloc_qta-date_to,
        quantity  TYPE zif_allocation=>ty_quantity,
      END OF ty_quota.
    TYPES ty_quota_tab TYPE STANDARD TABLE OF ty_quota WITH EMPTY KEY.

    "! What one customer was confirmed against one quota row.
    TYPES:
      BEGIN OF ty_taken,
        kunnr    TYPE vbak-kunnr,
        quantity TYPE zif_allocation=>ty_quantity,
      END OF ty_taken.
    TYPES ty_taken_tab TYPE STANDARD TABLE OF ty_taken WITH EMPTY KEY.

    DATA mo_store     TYPE REF TO zif_allocation_store.
    DATA mo_authority TYPE REF TO zif_allocation_authority.

    METHODS quotas_of
      IMPORTING
        iv_werks        TYPE mard-werks
        iv_matnr        TYPE mard-matnr
      RETURNING
        VALUE(rt_quota) TYPE ty_quota_tab.

    METHODS taken_against
      IMPORTING
        is_quota        TYPE ty_quota
        it_recorded     TYPE zif_allocation_store=>ty_recorded_tab
      RETURNING
        VALUE(rt_taken) TYPE ty_taken_tab.

    METHODS format_row
      IMPORTING
        iv_matnr       TYPE string
        iv_kunnr       TYPE string
        iv_period      TYPE string
        iv_quota       TYPE string
        iv_taken       TYPE string
        iv_left        TYPE string
      RETURNING
        VALUE(rv_line) TYPE string.

ENDCLASS.


CLASS zcl_alloc_quota_list IMPLEMENTATION.

  METHOD create_default.

    ro_list = NEW zcl_alloc_quota_list(
      io_store     = NEW zcl_allocation_store( )
      io_authority = NEW zcl_authority_alloc( c_activity_display ) ).

  ENDMETHOD.

  METHOD constructor.

    mo_store     = io_store.
    mo_authority = io_authority.

  ENDMETHOD.

  METHOD run.

    DATA lv_left TYPE zif_allocation=>ty_quantity.

    mo_authority->check_plant( iv_werks ).

    APPEND |Plant { iv_werks }, how the quotas stand| TO rt_line.

    DATA(lt_quota) = quotas_of(
      iv_werks = iv_werks
      iv_matnr = iv_matnr ).

    IF lt_quota IS INITIAL.
      APPEND `No quota is agreed here` TO rt_line.
      RETURN.
    ENDIF.

    " what the last run of each material confirmed, read once for the whole
    " plant rather than once per quota row
    DATA(lt_recorded) = mo_store->latest_per_material(
      iv_werks = iv_werks
      iv_matnr = iv_matnr ).

    APPEND format_row(
      iv_matnr  = `Material`
      iv_kunnr  = `Customer`
      iv_period = `Period`
      iv_quota  = `Agreed`
      iv_taken  = `Taken`
      iv_left   = `Left` ) TO rt_line.

    LOOP AT lt_quota INTO DATA(ls_quota).

      LOOP AT taken_against( is_quota    = ls_quota
                             it_recorded = lt_recorded ) INTO DATA(ls_taken).

        lv_left = ls_quota-quantity - ls_taken-quantity.
        IF lv_left < 0.
          CLEAR lv_left.
        ENDIF.

        APPEND format_row(
          iv_matnr  = |{ ls_quota-matnr }|
          iv_kunnr  = |{ ls_taken-kunnr }|
          iv_period = |{ ls_quota-date_from DATE = ISO } to { ls_quota-date_to DATE = ISO }|
          iv_quota  = |{ ls_quota-quantity }|
          iv_taken  = |{ ls_taken-quantity }|
          iv_left   = |{ lv_left }| ) TO rt_line.

      ENDLOOP.

    ENDLOOP.

  ENDMETHOD.

  METHOD quotas_of.

    IF iv_matnr IS INITIAL.
      SELECT matnr, kunnr, date_from, date_to, quantity
        FROM zstock_alloc_qta
        WHERE werks = @iv_werks
        ORDER BY matnr, kunnr, date_from
        INTO TABLE @rt_quota.
      IF sy-subrc <> 0.
        CLEAR rt_quota.
      ENDIF.
    ELSE.
      SELECT matnr, kunnr, date_from, date_to, quantity
        FROM zstock_alloc_qta
        WHERE werks = @iv_werks
          AND matnr = @iv_matnr
        ORDER BY matnr, kunnr, date_from
        INTO TABLE @rt_quota.
    ENDIF.
    IF sy-subrc <> 0.
      CLEAR rt_quota.
    ENDIF.

  ENDMETHOD.

  METHOD taken_against.

    DATA ls_taken TYPE ty_taken.

    LOOP AT it_recorded INTO DATA(ls_recorded).

      IF ls_recorded-matnr <> is_quota-matnr
          OR ls_recorded-customer IS INITIAL
          OR ls_recorded-confirmed <= 0.
        CONTINUE.
      ENDIF.

      " a row that names a customer is about that customer; one that names
      " none is the rule of the house, and the house rule is a limit each
      " customer runs into separately rather than one they share
      IF is_quota-kunnr IS NOT INITIAL AND ls_recorded-customer <> is_quota-kunnr.
        CONTINUE.
      ENDIF.

      IF ls_recorded-req_date < is_quota-date_from
          OR ls_recorded-req_date > is_quota-date_to.
        CONTINUE.
      ENDIF.

      READ TABLE rt_taken INTO ls_taken
        WITH KEY kunnr = ls_recorded-customer.
      IF sy-subrc = 0.
        ls_taken-quantity = ls_taken-quantity + ls_recorded-confirmed.
        MODIFY rt_taken FROM ls_taken
          TRANSPORTING quantity
          WHERE kunnr = ls_taken-kunnr.
        CONTINUE.
      ENDIF.

      ls_taken-kunnr    = ls_recorded-customer.
      ls_taken-quantity = ls_recorded-confirmed.
      APPEND ls_taken TO rt_taken.

    ENDLOOP.

    IF rt_taken IS NOT INITIAL.
      SORT rt_taken BY kunnr ASCENDING.
      RETURN.
    ENDIF.

    " a quota nobody has taken anything against is the one worth seeing: it is
    " either a promise nobody is using or a figure somebody typed wrongly
    ls_taken-kunnr = COND #( WHEN is_quota-kunnr IS NOT INITIAL
                             THEN is_quota-kunnr
                             ELSE c_anybody ).
    CLEAR ls_taken-quantity.
    APPEND ls_taken TO rt_taken.

  ENDMETHOD.

  METHOD format_row.

    rv_line = |{ iv_matnr WIDTH = c_width_matnr }|
           && |{ iv_kunnr WIDTH = c_width_kunnr }|
           && |{ iv_period WIDTH = c_width_period }|
           && |{ iv_quota WIDTH = c_width_qty ALIGN = RIGHT }|
           && |{ iv_taken WIDTH = c_width_qty ALIGN = RIGHT }|
           && |{ iv_left WIDTH = c_width_qty ALIGN = RIGHT }|.

  ENDMETHOD.

ENDCLASS.
