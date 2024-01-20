/**
 * Copyright (C) 2022-2023  Stefan Löffler
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation; either version 2, or (at your option) any later
 * version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
 * more details.
 */
#ifndef GUIDELINEEDITDIALOG_H
#define GUIDELINEEDITDIALOG_H

#include "ui_GuidelineEditDialog.h"

#include "PhysicalUnits.h"

#include <QDialog>
#include <QVector>

namespace QtPDF {

class PDFGuideline;

class GuidelineEditDialog : public QDialog, private Ui::GuidelineEditDialog
{
  Q_OBJECT
public:
  using size_type = QVector<int>::size_type;

  explicit GuidelineEditDialog(PDFGuideline * parent);

  size_type guidelinePage() const;
  void setGuidelinePage(const size_type p);

  Physical::Length guidelinePos() const;
  void setGuidelinePos(const Physical::Length & pos);

  size_type numPages() const;
  void setNumPages(const size_type n);

  Physical::Length::Unit unit() const { return m_unit; }
  void setUnit(const Physical::Length::Unit unit);

private:
  void convertPositionToNewUnit();
  Physical::Length::Unit m_unit{Physical::Length::Centimeters};
};

} // namespace QtPDF

#endif // GUIDELINEEDITDIALOG_H
