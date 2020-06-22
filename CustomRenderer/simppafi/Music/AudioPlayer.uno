using Uno;
using Uno.Collections;
using Fuse;
using Experimental.Audio;

namespace simppafi
{
	public class AudioPlayer
	{
		private Player 	_player = new Player();
		private Sound 	_sound;
		private Channel _channel;

		public bool HasSound = false;

		public AudioPlayer(int bpm = 120)
		{
			this.BPM = bpm;
		}

		public void SetSong(Uno.IO.BundleFile file)
		{
			_sound = _player.CreateSound(file);
		}

		public void Pause()
		{
			if(_channel != null)
				_channel.Pause();
		}
		public void Resume()
		{
			if(_sound != null && !HasSound)
			{
				_channel = _player.PlaySound(_sound, false);
				debug_log _sound;
				debug_log _channel;
				HasSound = true;
				_channel.Play();
			}
			if(_channel != null)
			{
				//debug_log "nochannel";
				_channel.Play();
			}
		}

		public bool IsPlaying
		{
			get {return (_channel != null) ? _channel.IsPlaying : false;}
		}

		public double Position
		{
			get { return _channel != null ? _channel.Position : 0;}
			set {
				if(_channel != null)
					_channel.Position = value;
			}
		}

		private int _tickpos;
		public int TickPosition
		{
			get {return _tickpos;}
			set {
				_tickpos = value;
				var t = 60000f / (_bpm * 4f);
				_channel.Position = (t/1000)*value;
			}
		}

		private int _bpm = 120;
		public int BPM
		{
			get {return _bpm;}
			set {_bpm = value;}
		}

	}
}
