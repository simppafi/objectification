using Uno;
using Uno.Collections;
using Uno.Graphics;
using Uno.Content;
using Uno.Content.Models;

namespace Fuse.Drawing.Batching
{
	public class BatchIndexBuffer
	{
		IndexType dataType;
		public IndexType DataType
		{
			get { return dataType; }
			set
			{
				if (buf != null) throw new Exception("Index type cannot be changed after buffer is written to");
				dataType = value;
			}
		}

		public int StrideInBytes { get { return IndexTypeHelpers.GetStrideInBytes(DataType); } }

		int maxIndices;

		BufferUsage usage;

		public BatchIndexBuffer(IndexType type, int maxIndices, bool staticBatch)
		{
			dataType = type;
			this.maxIndices = maxIndices;
			this.usage = staticBatch ? BufferUsage.Immutable : BufferUsage.Dynamic;
		}

		public BatchIndexBuffer(IndexType type, Buffer data)
		{
			this.DataType = type;
			this.usage = BufferUsage.Immutable;
			this.buf = new Uno.Buffer(data.SizeInBytes);
			for (int i =0; i<buf.SizeInBytes; i++)
				this.buf[i] = data[i];
		}

		Buffer buf;
		public Buffer Buffer
		{
			get
			{
				if (buf == null) buf = new Buffer(maxIndices * StrideInBytes);
				return buf;
			}
		}

		int _position;
		public int Position
		{
			get { return _position; }
			set { _position = value; }
		}

		public void Write(byte value)
		{
			Buffer.Set(_position, value);
			_position += 1;
		}

		public void Write(ushort value)
		{
			Buffer.Set(_position, value);
			_position += 2;
		}

		IndexBuffer ibo;
		public IndexBuffer IndexBuffer
		{
			get
			{
				if (buf == null)
					return null;

				if (ibo == null)
					this.ibo = new IndexBuffer(Buffer.SizeInBytes, usage);

				Flush();
				return ibo;
			}
		}

		bool isDirty = true;
		public void Flush()
		{
			if (buf != null && isDirty)
			{
				ibo.Update(buf);
				isDirty = false;
			}
		}

		public void Invalidate()
		{
			isDirty = true;
		}
	}
}
