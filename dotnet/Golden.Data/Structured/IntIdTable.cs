using Microsoft.SqlServer.Server;
using System;
using System.Collections.Generic;
using System.Data;

namespace Golden.Data.Structured
{
    public class IntIdTable : IEnumerable<SqlDataRecord>
    {
        private IEnumerable<int> _items;

        public IntIdTable(IEnumerable<int> items)
        {
            _items = items;
        }

        private static SqlDataRecord GetRecord()
        {
            return new SqlDataRecord(
                    new SqlMetaData[] { new SqlMetaData("Data", SqlDbType.Int) }
               );
        }

        public IEnumerator<SqlDataRecord> GetEnumerator()
        {
            if (_items != null)
            {
                foreach (int item in _items)
                {
                    var rec = GetRecord();

                    rec.SetInt32(0, item);

                    yield return rec;
                }
            }

            yield break;
        }

        System.Collections.IEnumerator System.Collections.IEnumerable.GetEnumerator()
        {
            return GetEnumerator();
        }
    }
}