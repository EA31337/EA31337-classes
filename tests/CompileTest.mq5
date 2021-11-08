//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2021, EA31337 Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/*
 *  This file is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.

 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.

 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/**
 * @file
 * Test compilation of all class files.
 */

// 3D includes (MQL5 only).
#ifdef __MQL5__
#include "../3D/Chart3D.h"
#include "../3D/Cube.h"
#include "../3D/Devices/MTDX/MTDXDevice.h"
#include "../3D/Devices/MTDX/MTDXIndexBuffer.h"
#include "../3D/Devices/MTDX/MTDXShader.h"
#include "../3D/Devices/MTDX/MTDXVertexBuffer.h"
#include "../3D/Frontends/MT5Frontend.h"
#endif

// Includes.
#include "../Account.mqh"
#include "../Action.mqh"
#include "../Array.mqh"
//#include "../BasicTrade.mqh" // @removeme
#include "../Buffer.mqh"
#include "../BufferStruct.mqh"
#include "../Chart.mqh"
#include "../Collection.mqh"
#include "../Condition.mqh"
#include "../Config.mqh"
#include "../Convert.mqh"
#include "../Database.mqh"
#include "../DateTime.mqh"
#include "../Dict.mqh"
#include "../DictBase.mqh"
#include "../DictIteratorBase.mqh"
#include "../DictObject.mqh"
#include "../DictSlot.mqh"
#include "../DictStruct.mqh"
#include "../Draw.mqh"
#include "../DrawIndicator.mqh"
#include "../EA.mqh"
#include "../File.mqh"
#include "../ISerializable.h"
#include "../Indicator.define.h"
#include "../Indicator.mqh"
#include "../IndicatorData.mqh"
#include "../Inet.mqh"
#include "../Log.mqh"
#include "../MD5.mqh"
#include "../Storage/IValueStorage.h"
//#include "../MQL4.mqh" // @removeme
//#include "../MQL5.mqh" // @removeme
#include "../Mail.mqh"
#include "../Market.mqh"
#include "../Math.h"
#include "../Matrix.mqh"
#include "../MiniMatrix.h"
#include "../Msg.mqh"
#include "../Object.mqh"
#include "../Order.mqh"
#include "../Orders.mqh"
#include "../Pattern.mqh"
#include "../Profiler.mqh"
#include "../Redis.mqh"
#include "../Refs.mqh"
#include "../Registry.mqh"
#include "../RegistryBinary.mqh"
#include "../Report.mqh"
#include "../Storage/Objects.h"
#include "../Storage/ObjectsCache.h"
// #include "../SVG.mqh" // @removeme
#include "../Serializer.mqh"
#include "../SerializerBinary.mqh"
#include "../SerializerConversions.h"
#include "../SerializerConverter.mqh"
#include "../SerializerCsv.mqh"
#include "../SerializerDict.mqh"
#include "../SerializerJson.mqh"
#include "../SerializerNode.mqh"
#include "../SerializerNodeIterator.mqh"
#include "../SerializerNodeParam.mqh"
#include "../SerializerObject.mqh"
#include "../SerializerSqlite.mqh"
#include "../Session.mqh"
#include "../SetFile.mqh"
#include "../Socket.mqh"
#include "../Stats.mqh"
#include "../Std.h"
#include "../Storage/Singleton.h"
#include "../Strategy.mqh"
#include "../String.mqh"
#include "../SummaryReport.mqh"
#include "../SymbolInfo.mqh"
#include "../Task.mqh"
#include "../Terminal.mqh"
// #include "../Tester.mqh" // @removeme
#include "../Storage/ValueStorage.h"
#include "../Tests.mqh"
#include "../Ticker.mqh"
#include "../Timer.mqh"
#include "../Trade.mqh"
#include "../Util.h"
#include "../Web.mqh"

// Includes indicator files.
#include "../Indicators/indicators.h"

/**
 * Implements Init event handler.
 */
int OnInit() { return (_LastError == ERR_NO_ERROR ? INIT_SUCCEEDED : INIT_FAILED); }
