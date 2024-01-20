/*
	This is part of TeXworks, an environment for working with TeX documents
	Copyright (C) 2017-2024  Jonathan Kew, Stefan Löffler, Charlie Sharpsteen

	This program is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; either version 2 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>.

	For links to further information, or to contact the authors,
	see <http://www.tug.org/texworks/>.
*/
#include "BibTeXFile.h"

#include <QFile>
#include <QTextCodec>

BibTeXFile::Entry::Type BibTeXFile::Entry::type() const
{
	if (_type.toLower() == QString::fromLatin1("comment"))
		return COMMENT;
	if (_type.toLower() == QString::fromLatin1("preamble"))
		return PREAMBLE;
	if (_type.toLower() == QString::fromLatin1("string"))
		return STRING;
	return NORMAL;
}

QString BibTeXFile::Entry::howPublished() const
{
	if (_cache.valid) {
		return _cache.howPublished;
	}
	if (hasField(QString::fromLatin1("howpublished"))) {
		return value(QString::fromLatin1("howpublished"));
	}
	if (hasField(QStringLiteral("journal"))) {
		return value(QString::fromLatin1("journal"));
	}
	return value(QString::fromLatin1("booktitle"));
}

QString BibTeXFile::Entry::value(const QString & key) const
{
	QString retVal;
	for (QMap<QString, QString>::const_iterator it = _fields.constBegin(); it != _fields.constEnd(); ++it) {
		if (QString::compare(key, it.key(), Qt::CaseInsensitive) == 0) {
			retVal = it.value();
			break;
		}
	}
	// strip surrounding {} (if any)
	if (retVal.startsWith(QLatin1Char('{')) && retVal.endsWith(QLatin1Char('}')))
		retVal = retVal.mid(1, retVal.length() - 2);
	// or surrounding "" (if any)
	else if (retVal.startsWith(QLatin1Char('"')) && retVal.endsWith(QLatin1Char('"')))
		retVal = retVal.mid(1, retVal.length() - 2);
	return retVal;
}

bool BibTeXFile::Entry::hasField(const QString & key) const
{
	for (QMap<QString, QString>::const_iterator it = _fields.constBegin(); it != _fields.constEnd(); ++it) {
		if (QString::compare(key, it.key(), Qt::CaseInsensitive) == 0)
			return true;
	}
	return false;
}

void BibTeXFile::Entry::updateCache()
{
	// invalidate cache so that all subsequent method calls actually search the
	// fields
	_cache.valid = false;
	_cache.author = author();
	_cache.howPublished = howPublished();
	_cache.title = title();
	_cache.year = year();
	_cache.valid = true;
}

bool BibTeXFile::load(const QString & filename)
{
	QFile file(filename);
	QByteArray content;
	QTextCodec * codec = QTextCodec::codecForName("utf-8");
	size_type curPos = 0;

	_entries.clear();

	if (!file.open(QFile::ReadOnly | QFile::Text))
		return false;

	content = file.readAll();
	file.close();

	// FIXME: Encoding detection
	if (!codec)
		return false;

	do {
		Entry e(this);
		curPos = readEntry(e, content, curPos, codec);
		if (curPos > 0) {
			e.updateCache();
			_entries.append(e);
		}
		// DEBUG
	} while(curPos > 0);

	return true;
}

template <class S, class C> BibTeXFile::size_type findBlock(const S & content, const BibTeXFile::size_type from, const C & startDelim, const C & endDelim, const C & escapeChar)
{
	using size_type = BibTeXFile::size_type;
	// Blocks are enclosed in {}.
	if (content[from] != startDelim)
		return -1;

	size_type open = 1;
	size_type i{from + 1};
	bool escaped = false;
	for (i = from + 1; i < content.size() && open > 0; ++i) {
		if (escaped) escaped = false;
		else if (content[i] == escapeChar) escaped = true;
		// put endDelim check before startDelim check to ensure proper handling
		// of startDelim == endDelim (e.g., '"')
		else if (content[i] == endDelim) --open;
		else if (content[i] == startDelim) ++open;
	}
	if (open == 0) return i - 1;
	return -1;
}

inline BibTeXFile::size_type findBlock(const QByteArray & content, const BibTeXFile::size_type from, char startDelim = '{', char endDelim = '}', char escapeChar = 0)
{
	return findBlock<QByteArray, char>(content, from, startDelim, endDelim, escapeChar);
}

inline BibTeXFile::size_type findBlock(const QString & content, const BibTeXFile::size_type from, const QChar & startDelim = QChar::fromLatin1('{'), const QChar & endDelim = QChar::fromLatin1('}'), const QChar & escapeChar = QChar())
{
	return findBlock<QString, QChar>(content, from, startDelim, endDelim, escapeChar);
}

// static
BibTeXFile::size_type BibTeXFile::readEntry(Entry & e, const QByteArray & content, const size_type startPos, const QTextCodec * codec)
{
	size_type curPos = content.indexOf('@', startPos);
	if (curPos < 0)
		return -1;
	++curPos;
	size_type start = content.indexOf('{', curPos);
	if (start < 0)
		return -1;
	e._type = codec->toUnicode(content.mid(curPos, start - curPos));

	size_type end = findBlock(content, start);
	if (end < 0) return -1;
	++start;
	QByteArray block = content.mid(start, end - start);

	switch (e.type()) {
	case Entry::COMMENT:
		e._key = codec->toUnicode(block);
		break;
	case Entry::PREAMBLE:
		e._key = codec->toUnicode(block);
		break;
	case Entry::STRING:
		// FIXME
		parseFields(e, codec->toUnicode(block));
		break;
	case Entry::NORMAL:
		parseEntry(e, codec->toUnicode(block));
		break;
	}

	return end + 1;
}

//static
void BibTeXFile::parseEntry(Entry & e, const QString & block)
{
	size_type pos = block.indexOf(QChar::fromLatin1(','));
	e._key = block.mid(0, pos).trimmed();
	if (pos == -1) return;

	parseFields(e, block, pos + 1);
}

void BibTeXFile::parseFields(BibTeXFile::Entry & e, const QString & block, const size_type startPos)
{
	QChar startDelim, endDelim;
	size_type pos{startPos};

	do {
		size_type start{pos};
		pos = block.indexOf(QChar::fromLatin1('='), start);
		if (pos < 0) break;
		const QString key = block.mid(start, pos - start).trimmed();
		QString val;

		start = -1;

		// Skip initial whitespace
		size_type i;
		for (i = pos + 1; i < block.size() && start < 0; ++i) {
			if (!block[i].isSpace()) start = i;
		}

		for (i = start; i < block.size(); ++i) {
			if (block[i] == QChar::fromLatin1(',')) {
				// Skip ',' and break out of the loop
				++i;
				break;
			}
			if (block[i] == QChar::fromLatin1('{')) {
				startDelim = QChar::fromLatin1('{');
				endDelim = QChar::fromLatin1('}');
			}
			else if (block[i] == QChar::fromLatin1('"')) {
				startDelim = QChar::fromLatin1('"');
				endDelim = QChar::fromLatin1('"');
			}
			else {
				val += block[i];
				continue;
			}

			size_type end = findBlock(block, i, startDelim, endDelim);
			if (end < 0) {
				val += block.mid(i);
				i = block.size();
			}
			else {
				val += block.mid(i, end - i + 1);
				i = end;
			}
		}
		e._fields[key] = val.trimmed();
		pos = i;
	} while (pos >= 0 && pos + 1 < block.size());
}

unsigned int BibTeXFile::numEntries() const
{
	// Only count "normal" entries
	unsigned int retVal = 0;
	for (int i = 0; i < _entries.size(); ++i) {
		if (_entries[i].type() == Entry::NORMAL) ++retVal;
	}
	return retVal;
}

QMap<QString, QString> BibTeXFile::strings() const
{
	QMap<QString, QString> rv;

	for (const Entry & e : _entries) {
		if (e.type() == Entry::STRING) {
#if QT_VERSION < QT_VERSION_CHECK(5, 15, 0)
			rv.unite(e._fields);
#else
			rv.insert(e._fields);
#endif
		}
	}
	return rv;
}

const BibTeXFile::Entry & BibTeXFile::entry(const unsigned int idx) const
{
	unsigned int j = 0;
	for (int i = 0; i < _entries.size(); ++i) {
		if (_entries[i].type() != Entry::NORMAL) continue;
		if (j == idx) return _entries[i];
		++j;
	}
	// We should never get here
	static BibTeXFile::Entry e(nullptr);
	return e;
}
